_ = require("underscore")
$ = require("jquery")
async = require("async")
CardFactory = require("./cardfactory")
Deck = require("./deck")
EE = require("../common/ee")
util = require("util")

stripUndefineds = (d) -> return typeof d != "undefined" # TODO: move into a lib?

class Dealer extends EE
  signal: "dealer"
  default_rules: {
    decks: 6,
    seats: 5,
    currency: "Chip",
    bet: {
      min: 10,
      max: 100
    },
    countdown: 20000,
    dealer: {
      can_hit: (count) ->
        return count < 17
      should_shuffle: (D) ->
        return D.cards_remaining() <= Math.floor(.25 * D.cards_total())
    },
    player_reward: {
      withhold: (bet) -> return -bet
      blackjack: (bet) -> return Math.floor(1.5*bet)
      push: (bet) -> return bet
      win: (bet) -> return 2*bet
      lose: (bet) -> return 0 # already subtracted by withhold
    }
    use_hole: false
  }

  constructor: (@_tables, @ruleset = {}) ->
    @rules = $.extend(true, {}, @default_rules, @ruleset)
    @games = {}
    @listeners = {}
    @create(name, meta) for own name, meta of @_tables

  update: (err, data, callback) ->
    return callback(err) if err
    return callback("Data must exist & supply a .type") if not data?.action?

    console.log("Lobby triggered: update(#{err}, #{JSON.stringify(data)})")
    switch data.action
      when "sit"
        return @add_player(data.table_name, data.user, data.onUpdate, callback)
      when "stand"
        return @remove_player(data.table_name, data.user, callback)
      else 
        # Ignore other actions
  
  # "Public" API (javascript has no public/private distinction, this is more of a convention)
  create: (name, meta) ->
    deck = new Deck(@rules.decks)
    @games[name] = {
      meta: meta,
      hand_in_progress: false,
      deck: deck, 

      seats: [],
      players: {},
      hands: {},
      dealer: {
        hand: []
      },

      queued: [], # sat down while hand_in_progress, will be seated next hand
      idle: [], # idle, locked out of game until place bet
      twiddling: [], # won or lost, no actions available til next hand

      timer: null,
      interact_timer: null,
      join_timer: null,
      idle_timer: null,
      countdown: null
    }
    @games[name].deck.shuffle()
  
  add_player: (table_name, user, on_update, callback) ->
    return callback("No such table found.") if not @games[table_name]?
    return callback("Invalid user supplied") if not user?.username? # TODO: expand into @validate_user()?
    
    username = user.username
    if @games[table_name].hand_in_progress
      @games[table_name].queued.push(username)
      
      # If single-player mode (no time limits): check for idle player
      if @_single_player(table_name) 
        nametag = @games[table_name].seats[0]
        player_one = @games[table_name].players[nametag]
        last_action = player_one.last_action
        player_one_idled = (+new Date() - last_action >= (2*@rules.countdown))

        if last_action and player_one_idled
          @_set_player_idle(table_name, player_one)
          @start_game(table_name)
    else
      @games[table_name].seats.push(username)
      @games[table_name].players[username] = user
      @games[table_name].hands[username] = []
    
    @emit(@_signal(table_name), null, {
      username: username,
      action: "joined",
      ts: +new Date()
    })
    @on(@_signal(table_name), on_update) # Ack player => request Bet amt
    @sanitize(table_name, callback) # TODO: make all players cards visible (wrong assumption earlier)
  
  remove_player: (table_name, user, callback) ->
    return callback("No such table found.") if not @games[table_name]?
    return callback("Invalid user supplied") if not user?.username?
    return callback("Username should be a string") if typeof user.username != "string"
    return callback("Username must not be blank") if user.username == ""

    username = user.username 
    # TODO: decrease verbosity
    if username in @games[table_name].twiddling
      i = @games[table_name].twiddling.indexOf(username)
      delete @games[table_name].twiddling[i]
      @games[table_name].twiddling = @games[table_name].twiddling.filter(stripUndefineds)
    else
      if @games[table_name].hand_in_progress
        @_lose(table_name, user.username)
        i = @games[table_name].twiddling.indexOf(username)
        delete @games[table_name].twiddling[i]
        @games[table_name].twiddling = @games[table_name].twiddling.filter(stripUndefineds)
    
    seats = @games[table_name].seats
    index = seats.indexOf(username)
    delete seats[index]
    seats = seats.filter((d) -> typeof d != "undefined") # Table sizes are small so O(n) is no biggie
    delete @games[table_name].players[username]

    # TODO: re-evaluate need for listener here
    # if @listeners[username]?
    #   util.debug("this.games.length = #{@games.length}")
    #   util.debug("listener for #{username}")
    #   util.debug(@listeners[username].toString())
    #   @removeListener(@listeners[username])
    #   delete @listeners[username]
    
    callback(null, true)
  
  sanitize: (table_name, callback) ->
    d = _.clone(@games[table_name])
    delete d.deck
    callback(null, d)
    return d
  
  logErrorCallback: (func_name, args, callback = null, msg) ->
    util.debug("[#{func_name}]: #{msg}") # TODO: replace w/ winston ftw
    return callback(msg) if callback?
  
  place_bet: (table_name, user, amount, callback) ->
    return @logErrorCallback("Dealer.place_bet", arguments, callback, "Bet must be a non-zero integer") if not amount or not _.isNumber(amount) or _.isNaN(amount)
    return @logErrorCallback("Dealer.place_bet", arguments, callback, "Bet cannot be more than the maximum (100)") if amount > @rules.bet.max
    return @logErrorCallback("Dealer.place_bet", arguments, callback, "Bet cannot be less than the minimum (10)") if amount < @rules.bet.min
    return @logErrorCallback("Dealer.place_bet", arguments, callback, "No such table found") if not @games[table_name]
    self = this

    # Reset Player-Join Grace Period
    # clearTimeout(@games[table_name].join_timer) # TODO: timer is used twice for diff reasons, poss simult
    # delete @games[table_name].join_timer

    # Set bet for player & restart grace period if needed
    error = @_set_bet(table_name, user, amount)
    if error
      callback(response)
    else
      @games[table_name].players[user.username].last_action = +new Date()
      callback(null, amount)
    # if @games[table_name].hand_in_progress and @_single_player(table_name)
    #   util.debug("Single Player idle check not yet implemented... but called()")
    #   # @games[table_name].idle_timer = setTimeout((() ->
    #   #   clearTimeout(@games[table_name].idle_timer)
    #   #   delete @games[table_name].idle_timer

    #   #   first_player = self.games[table_name].players[self.games[table_name].seat[0]]
    #   #   if first_player.action == null # first_player is still idle
    #   #     self._set_player_idle(table_name, first_player)
    #   #     self.start_game(table_name)
    #   #   else
    #   #     # Just wait for next hand to start
    #   # ), @rules.countdown)
    # else
    #   @games[table_name].join_timer = setTimeout((() ->
    #     self.start_game(table_name)
    #   ), @rules.countdown)
  
  start_game: (table_name) ->
    throw "No such table exists" if not @games[table_name]?
    @games[table_name].hand_in_progress = true

    # Bring Queued players in
    for u in @games[table_name].queued
      @games[table_name].seats.push(u.username)
      @games[table_name].players[u.username] = u
      @_dequeue_user(u) # TODO: dbl check user types here
    
    # Pull out anyone who hasn't bet (incl any dequeued players who haven't)
    for nametag in @games[table_name].seats
      if not @_is_idle(table_name, nametag)
        if not @games[table_name].players[nametag].bet
          util.debug("#{username} has not set a bet and is being set to idle")
          @_set_player_idle(table_name, @games[table_name].players[nametag])
    
    # Shuffle deck if necessary
    if @rules.dealer.should_shuffle(@games[table_name].deck)
      @emit(@_signal(table_name), null, {
        username: "Dealer",
        action: "shuffling",
        ts: +new Date()
      })
      @games[table_name].deck.shuffle()
    
    # Deal out cards mimicking real dealer
    @_initial_deal(table_name)
    @_initial_deal(table_name)
    
    # TODO: convert hands to more user-friendly format?
    hands = _.clone(@games[table_name].hands)
    hands.dealer = []
    hands.dealer.push(@games[table_name].dealer.hand[0])

    blackjack_d = @_is_blackjack(@games[table_name].dealer.hand)
    if blackjack_d or not @rules.use_hole
      hands.dealer.push(@games[table_name].dealer.hand[1])

    # Emit state for client-side rendering
    game_state = {
      action: "start",
      hands: hands,
    }
    @emit(@_signal(table_name), null, game_state)

    util.debug("========================")
    util.debug("Game starts with:")
    util.debug("Dealer has: #{@_hand_value(@games[table_name].dealer.hand)} (#{JSON.stringify(@games[table_name].dealer.hand)})")
    util.debug("-----------------------")
    for nametag in @games[table_name].seats
      util.debug("#{nametag} has: #{@_hand_value(@games[table_name].hands[nametag])} (#{JSON.stringify(@games[table_name].hands[nametag])})")
      util.debug("-----------------------")
    util.debug("========================")

    # Loop over players & interact one at a time
    self = this
    async.mapSeries(@games[table_name].seats, (nametag, callback) ->
      self.games[table_name].turn = nametag
      self.interact_player(table_name, self.games[table_name].players[nametag], callback)
    , (err, active_players) ->
      if err
        self.emit(self._signal(table_name), err)
        self.logErrorCallback("Dealer.start_game", arguments, null, err)
        return null
      
      active_players = active_players.filter(stripUndefineds)
      table = self.games[table_name]
      seats = table.seats
      
      if seats.length == 0
        # Everyone left during game
        return @finish_hand(table_name)
      else
        # if active_players.length == 0
        #   # Everyone was idle
        #   for nametag in self.games[table_name].seats
        #     self._set_player_idle(table_name, self.games[table_name].players[nametag])
        
        if not blackjack_d and @rules.use_hole # Reveal hole card
          self.emit(self._signal(table_name), null, {
            actor: "The Dealer",
            verb: "revealed",
            object: "the hole card"
            target: self.games[table_name].dealer.hand[1]
          })
        
        # After all players have played, dealer plays
        while self.rules.dealer.can_hit(self._hand_value(table.dealer.hand))
          table.dealer.hand.push(self.games[table_name].deck.pop())
        
        self.final_evaluate(table_name, active_players)
    )
  
  final_evaluate: (table_name, unfinished_players) ->
    throw "No such table exists" if not @games[table_name]?
    self = this

    table = @games[table_name]
    dealer_hand = table.dealer.hand
    dealer_value = @_hand_value(table.dealer.hand)
    # bj_d = @_is_blackjack(dealer_hand)
    bust_d = @_is_bust(dealer_hand)
    
    for nametag in unfinished_players
      hand = table.hands[nametag]
      hand_value = @_hand_value(table.hands[nametag])
      bust_p = @_is_bust(hand)
      throw "final_evaluate.bust_p should be true for unfinished_player" if bust_p
      
      if bust_d
        verb = "wins"
        amt = @_win(table_name, nametag)
      else
        if hand_value == dealer_value
          verb = "pushes"
          amt = @_push(table_name, nametag)
        else if hand_value < dealer_value
          verb = "loses"
          amt = @_lose(table_name, nametag)
        else
          verb = "wins"
          amt = @_win(table_name, nametag)
      util.debug("#{nametag} #{verb} #{amt} (#{hand_value} vs #{dealer_value})")
    
    @finish_hand(table_name)

  finish_hand: (table_name) ->
    throw "No such table found ({#table_name})" if not @games[table_name]?
    clearTimeout(@games[table_name].timer)
    delete @games[table_name].timer
    @games[table_name].countdown = null

    util.debug("==================")
    util.debug("Game ends with:  ")
    util.debug("Dealer has: #{@_hand_value(@games[table_name].dealer.hand)}")
    for nametag in @games[table_name].seats
      util.debug("#{nametag} has: #{@_hand_value(@games[table_name].hands[nametag])} (#{JSON.stringify(@games[table_name].hands[nametag])})")
    util.debug("==================")

    for own username, player of @games[table_name].players
      @games[table_name].hands[username] = []
      @games[table_name].players[username].action = null
      # @games[table_name].players[username].bet = null # TODO: decide on repeatedly set bet or not
    
    @games[table_name].dealer.hand = []
    @games[table_name].twiddling = []
    @games[table_name].turn = null
    @games[table_name].hand_in_progress = false

    # If Singleplayer, this emit will ask user to deal
    @emit(@_signal(table_name), null, {
      actor: "The Dealer",
      verb: "ends",
      object: "the hand",
      target: _.clone(@games[table_name].players)
      published: new Date()
    })
  
  interact_player: (table_name, user, callback = null) ->
    # This function is recursively called to update player's state upon decisions (or force decision via timeout)
    return @logErrorCallback("interact_player", arguments, null, "No such table found (#{table_name})") if not @games[table_name]?
    self = this

    if not callback
      if @games[table_name].turn_cb and @games[table_name].turn == user.username
        callback = @games[table_name].turn_cb 
      else
        util.debug("FAIL: interact_player(#{table_name}, #{user.username}) has no callback or turn_cb (out of order execution)...")
    else
      @games[table_name].turn_cb = callback

      intercepted_callback = callback
      callback = (err, unfinished_player) ->
        self.games[table_name].turn = null
        intercepted_callback(err, unfinished_player)

    clearTimeout(@games[table_name].interact_timer)
    delete @games[table_name].interact_timer

    table = @games[table_name]
    username = user.username
    hand = table.hands[username]
    dealer_hand = table.dealer.hand
    
    bust_p = @_is_bust(hand)
    bust_d = @_is_bust(hand)
    bj_p = @_is_blackjack(hand)
    bj_d = @_is_blackjack(dealer_hand)
    wh_d = _.clone(table.players[username].action || null)

    # Break for important status conditions
    if bj_d and bj_p
      @_push(table_name, username)
      return callback(null, undefined)
    
    if bj_d and not bj_p
      @_lose(table_name, username)
      return callback(null, undefined)
    
    if not bj_d and bj_p
      @_win_blackjack(table_name, username)
      return callback(null, undefined)
    
    if bust_p
      @_lose(table_name, username) # even if dealer also busted
      return callback(null, undefined)
    
    if not wh_d # player's .action currently null => "First Move"
      # Request a decision from player
      @emit(@_signal(table_name), null, {
        actor: username,
        verb: "has",
        object: "turn",
        published: +new Date()
      })

      if @_single_player(table_name)
        # No time limit in single player mode
        # TODO: on player queue, set inactivity timer, set this player to idle & seat other
        if @games[table_name].inactivity_check_requested
          @games[table_name].inactivity_check_requested += 1
        else
          @games[table_name].inactivity_check_requested = 1
      else
        # Start stopwatch for inactivity
        @games[table_name].interact_timer = setTimeout((() ->
          # callback("#{username} is now idle.")
          util.debug("#{username} did not make a move within time limit")
          callback(null, null)
        ), @rules.countdown)
    else
      # Handle actions
      table.players[username].action = null

      # FUTURE: additional actions go here
      switch wh_d
        when "stand"
          util.debug("#{username} stands with #{JSON.stringify(@_hand_value(table.hands[username]))}, #{JSON.stringify(table.hands[username])}")
          return callback(null, username)
        when "hit"
          table.hands[username].push(@games[table_name].deck.pop())
          ihand = @games[table_name].hands[username]
          handval = @_hand_value(ihand)
          util.debug("#{username} hits to #{JSON.stringify(handval)}, #{JSON.stringify(ihand)}")
          return @interact_player(table_name, user, callback)
        else 
          @logErrorCallback("interact_player", arguments, callback, "Unsupported player action (#{wh_d}) requested.")
          return callback(null, username) # assume idle player wants to stand
  
  get_purse: (table_name, user, callback) ->
    # TODO: switch to a more authoritative version
    util.debug("Dealer.get_purse(" + JSON.stringify(arguments) + ")")
    if table_name not in _.keys(@games)
      console.log("#{user.username} is currently not seated => #{user.purse}")
      return callback(null, user.purse || 500)
    # try
    #   purse = @games[table_name].players[user.username].purse
    # catch error
    #   util.debug("get_pursex" + "error: " + JSON.stringify(error))
    #   purse = null
    # callback(null, purse) if callback
    # console.log("get_purse_g = ", JSON.stringify(purse))
    # return purse
  
  get_dealer_hand: (table_name) ->
    cards = []
    for card in @games[table_name].dealer.hand
      cards.push(@games[table_name].deck.CF.identify(card))
    return cards
  
  # TODO: replace @games[table_name] w/ shorthand, to eliminate multiple lookups
  # deal_one: (table_name) ->
    # throw "No such table exists" if not @games[table_name]?
    # @_deal(table_name)

  # deal: (table_name) ->
    # throw "No such table exists" if not @games[table_name]?
    # @games[table_name].hand_in_progress = true

    # # Bring Queued players in
    # for u in @games[table_name].queued
    #   @games[table_name].seats.push(u.username)
    #   @games[table_name].players[u.username] = u
    #   @_dequeue_user(u) # TODO: dbl check user types here
    
    # # Pull out anyone who hasn't bet (incl any queued players who haven't)
    # for own username, player of @games[table_name].players
    #   if not player.bet?
    #     @_set_player_idle(table_name, player)
    
    # # Shuffle deck if necessary
    # if @rules.dealer.should_shuffle(@games[table_name].deck)
    #   @emit(@_signal(table_name), null, {
    #     username: "Dealer",
    #     action: "shuffling",
    #     ts: +new Date()
    #   })
    #   @games[table_name].deck.shuffle()
    
    # # Deal out cards mimicking real dealer
    # @_deal(table_name)
    # @_deal(table_name)

    # @emit(@_signal(table_name), null, {
    #   username: "Dealer",
    #   action: "dealt",
    #   ts: +new Date()
    # })

    # # Evaluate results
    # @evaluate(table_name)

  request_action: (table_name, user, action, callback) ->
    return callback("No such table found") if not @games[table_name]?

    # Validate & set/request action
    # util.debug("requesting action (#{table_name}, #{user.username}, #{action}")
    switch action
      when "hit", "stand"
        util.debug("#{user.username} calls #{action}")
        return callback("Cannot #{action} while hand not in progress") if not @games[table_name].hand_in_progress
        return callback("Cannot #{action} until your turn") if @games[table_name].turn and user.username != @games[table_name].turn
        @games[table_name].players[user.username].action = action
        return @interact_player(table_name, user)
      when "deal"
        util.debug("#{user.username} calls to #{action}")
        return callback("Cannot request deal while hand in progress") if @games[table_name].hand_in_progress
        return callback("Cannot request deal with a group") if @games[table_name].seats.length > 1
        return @start_game(table_name)
      else 
        return callback("Unauthorized action performed (#{action})")
  
  # "Private" methods
  ## Gameplay::Hand handle outcomes
  _end: (table_name, username, outcome) ->
    # FUTURE: check if user is already twiddling
    bet = @games[table_name].players[username].bet
    reward = @rules.player_reward[outcome](bet)
    @games[table_name].players[username].purse += reward
    @games[table_name].twiddling.push(username)
    return reward
  
  _lose: (table_name, username) -> @_end(table_name, username, "lose")

  _win: (table_name, username) -> @_end(table_name, username, "win")

  _win_blackjack: (table_name, username) -> @_end(table_name, username, "blackjack")
  
  _push: (table_name, username) -> @_end(table_name, username, "push")

  ## Gameplay::Hand detection status conditions
  _is_blackjack: (hand) ->
    return false if hand.length > 2
    return false if @_hand_value(hand) != 21
    return true
  
  _is_bust: (hand) ->
    return true if @_hand_value(hand) > 21
    return false
  
  # TODO: dbl check this function, looks fishy
  _waiting: (table_name, user) ->
    util.debug("_waiting(#{table_name}, #{JSON.stringify(user)})")
    util.debug("seats.length == 1?   #{@games[table_name].seats.length == 1 }")
    return false if @games[table_name].seats.length == 1 

    for own username, player of @games[table_name].players
      util.debug("_waiting.loop:", username, player, player.action)
      if player.action == null
        return false
    return true

  _in_play: (table_name, username) ->
    util.debug("_in_play(#{table_name}, #{username}) action: ")
    util.debug(@games[table_name].players[username].action)
    return false if username in @games[table_name].twiddling
    return false if username in @games[table_name].idle
    return false if @games[table_name].players[username].action == "stand"
    return true
  
  ## Gameplay::Hand viewing
  _card_value: (index) ->
    throw "can't run _card_value on Ace" if index == 0
    throw "can't run _card_value on card higher than max" if index > 13 # TODO: use CardFactory/Deck
    return 10 if index > 10
    return index

  _hand_value: (hand) ->
    # hand ranks are zero-indexed: Ace = 0
    value = 0
    for card in hand
      if card.r != 0 
        value += @_card_value(card.r)
      else
        # Handle Ace case
        if value + 11 > 21
          value += 1
        else
          value += 11
    return value

  _get_player_hand: (table_name, user) ->
    self = this
    return @games[table_name].hands[user.username].map((c) ->
      card = self.games[table_name].deck.CF.identify(c)
      return card
    )
  
  ## Gameplay::Hand action related
  _initial_deal: (table_name) ->
    for nametag in @games[table_name].seats
      username = @games[table_name].players[nametag].username

      twiddling_p = username in @games[table_name].twiddling
      idle_p = username in @games[table_name].idle
      stand_p = @games[table_name].players[username].action == "stand"

      if twiddling_p or idle_p or stand_p
        continue
      else
        @games[table_name].hands[username] ?= []
        card = @games[table_name].deck.pop()
        @games[table_name].hands[username].push(card)
        # util.debug("dealing card (#{JSON.stringify(@_hand_value(card))}) to #{username}")
    
    dealer_value = @_hand_value(@games[table_name].dealer.hand)
    if @rules.dealer.can_hit(dealer_value)
      dcard = @games[table_name].deck.pop()
      @games[table_name].dealer.hand.push(dcard)
      # util.debug("dealer hits @ #{dealer_value} and gets #{JSON.stringify(@_hand_value(dcard))}")
    # else
    #   # util.debug("dealer stands @ #{dealer_value}")
  
  ## Gameplay conditionals
  _single_player: (table_name) ->
    player_count = @games[table_name].seats.length + @games[table_name].queued.length
    return player_count == 1
  
  _is_idle: (table_name, username) ->
    username = username.username if typeof username == "object" and username.username?
    return username in @games[table_name].idle
  
  _can_set_bet: (table_name, user) ->
    # Return null if can set bet; error message, if cannot
    idle = (user.username in @games[table_name].idle)
    queued = (user.username in @games[table_name].queued)
    err = "Cannot place bet while hand is in progress"

    if @games[table_name].hand_in_progress
      return err if not idle or not queued
      return @_dequeue_user(table_name, user) and @_twiddle_user(table_name, user) and null if queued
      return @_deidle_user(table_name, user) and @_twiddle_user() and null if idle
      return err # defensive programming
    else
      return @_dequeue_user(table_name, user) and @_seat_user(table_name, user) and null if queued
      return @_deidle_user(table_name, user) and null if idle
      return null
  
  ## Gameplay mutators
  _set_bet: (table_name, user, amount) ->
    return @logErrorCallback("_set_bet", arguments, null, "no such table_name found") if not @games[table_name]?
    @games[table_name].players[user.username].bet = amount
    @games[table_name].players[user.username].purse += @rules.player_reward["withhold"](amount)
  
  ## Common Array based functions
  # TODO: replace all array-based fns with master fn
  _queue_user: (table_name, user, unseat = true) ->
    @games[table_name].queued.push(user.username)
    @_unseat_user(table_name, user) if unseat
  
  # TODO: check function use matches prototype
  _dequeue_user: (table_name, user) ->
    index = @games[table_name].queued.indexOf(user.username)
    if index >= 0
      delete @games[table_name].queued[index]
      @games[table_name].queued = @games[table_name].queued.filter(stripUndefineds)
  
  _set_player_idle: (table_name, user, unseat = false) ->
    idle = @games[table_name].idle
    @games[table_name].idle.push(user.username)
    @_unseat_user(table_name, user) if unseat
    @emit(@_signal(table_name), null, {
      actor: user.username,
      verb: "is",
      object: "idle",
      published: new Date()
    })
  
  _deidle_user: (table_name, user) ->
    index = @games[table_name].idle.indexOf(user.username)
    if index >= 0
      delete @games[table_name].idle[index]
      @games[table_name].idle = @games[table_name].idle.filter(stripUndefineds)
      @emit(@_signal(table_name), null, {
        actor: user.username,
        verb: "is",
        object: "no longer idle",
        published: new Date()
      })
  
  _seat_user: (table_name, user) ->
    @games[table_name].seats.append(user.username) if user.username not in @games[table_name].seats

  _unseat_user: (table_name, user) ->
    index = @games[table_name].seats.indexOf(user.username)
    if index >= 0
      delete @games[table_name].seats[index]
      @games[table_name].seats = @games[table_name].seats.filter(stripUndefineds)
  

  
  
    
module.exports = Dealer