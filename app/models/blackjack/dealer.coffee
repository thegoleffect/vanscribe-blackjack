_ = require("underscore")
$ = require("jquery")
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
      should_hit: (count) ->
        return count < 17
      should_shuffle: (D) ->
        return D.cards_remaining() <= Math.floor(.25 * D.cards_total())
    },
    player_reward: {
      blackjack: (bet) -> return Math.floor(1.5*bet)
      push: (bet) -> return bet
      win: (bet) -> return bet
      lose: (bet) -> return -bet
    }
    use_hole: false,
  }

  constructor: (@_tables, @ruleset = {}) ->
    @rules = $.extend(true, {}, @default_rules, @ruleset)
    @games = {}
    @listeners = {}
    @create(name, meta) for own name, meta of @_tables

  update: (err, data, callback) ->
    return callback(err) if err
    return callback("Data must exist & supply a .type") if not data?.action?

    util.debug("update(#{err}, #{JSON.stringify(data)})")
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
      countdown: null
    }
    @games[name].deck.shuffle()
  
  add_player: (table_name, user, on_update, callback) ->
    return callback("No such table found.") if not @games[table_name]?
    return callback("Invalid user supplied") if not user?.username? # TODO: expand into @validate_user()?
    
    username = user.username
    if @games[table_name].hand_in_progress
      @games[table].queued.push(username)
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
    # TODO: dbl check if have to adjust this
    d = _.clone(@games[table_name])
    # delete d.hands
    callback(null, d)
  
  logErrorCallback: (func_name, args, callback = null, msg) ->
    util.debug("[#{func_name}]: #{msg}") # TODO: replace w/ winston ftw
    return callback(msg) if callback?
  
  place_bet: (table_name, user, amount, callback) ->
    return @logErrorCallback("Dealer.place_bet", arguments, callback, "Bet cannot be more than the maximum (100)") if amount > @rules.bet.max
    return @logErrorCallback("Dealer.place_bet", arguments, callback, "Bet cannot be less than the minimum (10)") if amount < @rules.bet.min
    self = this

    # Reset Player join Grace period
    clearTimeout(@games[table_name].timer) # TODO: timer is used twice for diff reasons, poss simult
    delete @games[table_name].timer

    # Set bet for player & restart grace period
    @_set_bet(table_name, user, amount)
    @games[table_name].timer = setTimeout((() ->
      self.start_game(table_name)
    ), @rules.countdown)
  
  start_game: (table_name) ->
    throw "No such table exists" if not @games[table_name]?
    self = this
    @games[table_name].hand_in_progress = true

    # Bring Queued players in
    for u in @games[table_name].queued
      @games[table_name].seats.push(u.username)
      @games[table_name].players[u.username] = u
      @_dequeue_user(u) # TODO: dbl check user types here
    
    # Pull out anyone who hasn't bet (incl any queued players who haven't)
    for nametag in @games[table_name].seats
      if not @_is_idle(table_name, nametag)
        if not player.bet
          @_idle_user(table_name, @games[table_name].players[nametag])

    # for own username, player of @games[table_name].players
    #   if not player.bet?
    #     @_idle_user(table_name, player) # TODO: $.uniq on idle array
    
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
    
    # TODO: convert hands to more user-friendly format
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

    # Loop over players & interact one at a time
    async.mapSeries(@games[table_name].seats, (nametag, callback) ->
      @interact_player(table_name, @games[table_name].players[nametag], callback)
    , (err, active_players) ->
      active_players = active_players.filter(stripUndefineds)

      if err
        @emit(@_signal(table_name), err)
        @logErrorCallback("Dealer.start_game", arguments, null, err)
        return null
      
      if active_players.length == 0
        # Everyone was idle
        for nametag in @games[table_name].seats
          @_idle_user(table_name, @games[table_name].players[nametag])
          # TODO: rename _idle_user to _idle_player to match conventions
      
      # After all players have played, dealer plays
      if @rules.use_hole
        @emit(@_signal(table_name), null, {action: "hole", card: @games[table_name].dealer.hand[1]})
      
      while @rules.dealer.should_hit(@_hand_value(table.dealer.hand))
        table.dealer.hand.push(@games[table_name].deck.pop())
      
      self.final_evaluate(table_name, active_players)
    )
  
  final_evaluate: (table_name, active_players) ->
    throw "No such table exists" if not @games[table_name]?
    self = this


    bust_p = @_is_bust(hand)
    bust_d = @_is_bust(hand)
    bj_p = @_is_blackjack(hand)
    bj_d = @_is_blackjack(dealer_hand)
    ch_d = @rules.dealer.should_hit(@_hand_value(dealer_hand))
    

    # first_player = @games[table_name].seats[0]
    # @interact_player(table_name, @games[table_name].players[first_player])
    # {
    #   # username: "Dealer",
    #   # action: "dealt",
    #   # ts: +new Date()
    #   action: "deal"
    # }
    # Evaluate results
    # @evaluate(table_name)
    # ineligible = @_can_set_bet(table_name, user)
    # if ineligible
    #   return callback(ineligible)
    # else
    #   @_set_bet(table_name, user, amount)
    
    # callback(null, amount) # TODO: client-side, respond by showing deal button
  
  interact_player: (table_name, user, callback) ->
    # This function is recursively called to update player's state upon decisions (or force decision via timeout)
    return @logErrorCallback("interact_player", arguments, null, "No such table found (#{table_name})") if not @games[table_name]?

    clearTimeout(@games[table_name].timer)
    delete @games[table_name].timer

    table = @games[table_name]
    username = user.username
    hand = table.hands[username]
    dealer_hand = table.dealer.hand
    
    bust_p = @_is_bust(hand)
    bust_d = @_is_bust(hand)
    bj_p = @_is_blackjack(hand)
    bj_d = @_is_blackjack(dealer_hand)
    # ch_d = @rules.dealer.should_hit(@_hand_value(dealer_hand))
    wh_d = table.players[username].action || null

    # Check for important status conditions
    if bj_p and not bj_d 
      # @_win_blackjack(table_name, username)
      return callback(null, username) # No user-input required
    
    if bust_p
      @_lose(table_name, username) # even if dealer also busted
      return callback(null, undefined)
    
    if not wh_d # player's .action currently null
      if @games[table_name].timer # timer already running = player was idle in single mode & another joined
        @_lose(table_name, username)
        @_idle_user(table_name, user)
        return @start_game(table_name)
      
      # Request decision from player
      @emit(@_signal(table_name), null, {
        username: username,
        action: "has turn",
        ts: +new Date()
      })

      if @_single_player(table_name)
        # No time limit in single player mode
        # TODO: on player queue, set inactivity timer, set this player to idle & seat other
      else
        # Start stopwatch for inactivity
        @games[table_name].timer = setTimeout((() ->
          callback("#{username} is now idle.")
        ), @rules.countdown)
    else
      # FUTURE: additional actions go here
      switch wh_d
        when "stand"
          return callback(null, username)
        when "hit"
          table.hands[username].push(@games[table_name].deck.pop())
          return interact_player(table_name, user, callback)
        else 
          return @logErrorCallback("interact_player", arguments, callback, "Unsupported player action (#{wh_d}) requested.")

  
  get_hands: (table_name, user, callback) ->
    return callback("You are not currently sitting at #{table_name}") if user.username not in _.keys(@games[table_name].players)
    self = this
    # hands = {
    #   dealer: @get_dealer_hand(table_name)
    # }
    hands = _.clone(@games[table_name].hands)
    hands["dealer"] = @get_dealer_hand(table_name)

    # if @games[table_name].hand_in_progress
    #   hands[user.username] = @_get_player_hand(table_name, user)
    # else
    #   for own username, hand of @games[table_name].hands
    #     hands[username] = @games[table_name].hands[username].map((c) ->
    #       card = self.games[table_name].deck.CF.identify(c)
    #       return card
    #     )
    
    callback(null, hands)

  get_dealer_hand: (table_name) ->
    cards = []
    for card in @games[table_name].dealer.hand
      cards.push(@games[table_name].deck.CF.identify(card))
    return cards
  
  # TODO: replace @games[table_name] w/ shorthand, to eliminate multiple lookups
  deal_one: (table_name) ->
    # throw "No such table exists" if not @games[table_name]?
    # @_deal(table_name)

  deal: (table_name) ->
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
    #     @_idle_user(table_name, player)
    
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
    util.debug("requesting action (#{table_name}, #{user.username}, #{action}")
    switch action
      when "hit", "stand"
        return callback("Cannot #{action} while hand not in progress.") if not @games[table_name].hand_in_progress
        @games[table_name].players[user.username].action = action
        util.debug("set #{user.username}.action to #{action}")
      when "deal"
        return callback("Cannot request deal while hand in progress") if @games[table_name].hand_in_progress
        return callback("Cannot request deal with a group") if @games[table_name].seats.length > 1
        return @deal(table_name)
      else 
        return callback("Unauthorized action performed (#{action})")
    
    # If last player to move or single-player => bypass the timer
    if not @_waiting(table_name, user)
      util.debug("not @_waiting() so go to force_eval")
      @force_evaluate(table_name)
    else
      # Do nothing
      util.debug("@_waiting() = true, so do nothing")
      # TODO: emit signal to indicate ready check
  
  force_evaluate: (table_name, callback = () ->) ->
    # util.debug("force_evaluate(#{table_name})")
    # return util.debug("No such Table found") if not @games[table_name]
    # return util.debug("Already done with hand") if not @games[table_name].hand_in_progress

    # # Reset the Clock
    # clearTimeout(@games[table_name].timer)
    # delete @games[table_name].timer
    # @games[table_name].countdown = null

    # # Sideline Idle Players
    # for own username, player of @games[table_name].players
    #   if player.action == null
    #     @_lose(table_name, player) if player.bet?
    #     @_idle_user(table_name, user)
    
    # @deal_one(table_name) # deals to ppl who hit
    
    # @evaluate(table_name)
  
  evaluate: (table_name) ->
    # TODO: I implemented the order wrong
    return

    # # util.debug("evaluate called(#{table_name})")
    # throw "No such table found" if not @games[table_name]?

    # outcomelog = (username, verb, value, dealer_hand) ->
    #   util.debug("#{username} #{verb} with #{value} to dealer's #{dealer_hand}")

    # # util.debug(JSON.stringify(@games[table_name].dealer))
    # # util.debug(JSON.stringify(@games[table_name].hands))
    # dealer_hand = @games[table_name].dealer.hand
    # dealer_value = @_hand_value(dealer_hand)

    # for own username, hand of @games[table_name].hands
    #   continue if username in @games[table_name].twiddling # skip players who are waiting
    #   continue if username in @games[table_name].idle
    #   # util.debug("evaluating #{username}")
    #   if @_is_bust(hand)
    #     outcomelog(username, "loses", @_hand_value(hand), dealer_value)
    #     @_lose(table_name, username)
    #   else
    #     if @_is_bust(dealer_hand)
    #       outcomelog(username, "wins", @_hand_value(hand), dealer_value)
    #       @_win(table_name, username)
    #     else
    #       if @_is_blackjack(hand)
    #         if @_is_blackjack(@games[table_name].dealer.hand)
    #           outcomelog(username, "pushes", @_hand_value(hand), dealer_value)
    #           @_push(table_name, username)
    #         else
    #           outcomelog(username, "wins blackjack", @_hand_value(hand), dealer_value)
    #           @_win_blackjack(table_name, username)
    #       else
    #         if @_is_blackjack(@games[table_name].dealer.hand)
    #           outcomelog(username, "loses blackjack", @_hand_value(hand), dealer_value)
    #           @_lose(table_name, username)
    #         else
    #           if not @rules.dealer.should_hit(dealer_value)
    #             # util.debug("dealer can't hit and #{username} hasn't bust")
    #             if dealer_value < @_hand_value(hand)
    #               outcomelog(username, "wins", @_hand_value(hand), dealer_value)
    #               @_win(table_name, username)
    #             else if dealer_value == @_hand_value(hand)
    #               @_push(table_name, username)
    #             else
    #               outcomelog(username, "hasn't lost yet (dealer can't hit)", @_hand_value(hand), dealer_value)
    #               continue
    #           else
    #             # util.debug("dealer can hit, neither has bust")
    #             outcomelog(username, "hasn't lost yet (but dealer can hit)", @_hand_value(hand), dealer_value)
    #             continue

    # # Clear user actions
    # for own username, player of @games[table_name].players
    #   # util.debug("should clear user action for: #{username}: ")
    #   # util.debug("@games[table_name].players[username]'s value pre clear")
    #   # util.debug(JSON.stringify(@games[table_name].players[username]))
    #   try
    #     @games[table_name].players[username].action = null
    #   catch error
    #     # util.debug("unable to clear #{username}'s action")
    #     util.debug(JSON.stringify(error))
    
    # # util.debug("all actions cleared")
    # num_finished_players = @games[table_name].idle.length + @games[table_name].twiddling.length
    
    # # return num_finished_players == (@games[table_name].seats.length) # TODO: dbl check math

    # game_over = num_finished_players == (@games[table_name].seats.length)
    # # util.debug("num_finished_players, seats, eq? = #{num_finished_players}, #{@games[table_name].seats.length}, #{game_over}")
    # if not game_over
    #   if @games[table_name].seats.length == 1
    #     util.debug("Single player mode detected.  User should hit or stand.")
    #   else
    #     util.debug("Multiplayer mode detected, users have #{@rules.countdown/1000} seconds to request_action")
    #     self = this
    #     @games[table_name].countdown = new Date((+new Date()) + @rules.countdown)
    #     @games[table_name].timer = setTimeout((() ->
    #       self.force_evaluate(table_name)
    #     ), @rules.countdown)
    # else
    #   @finish_hand(table_name)

  finish_hand: (table_name) ->
    # throw "No such table found ({#table_name})" if not @games[table_name]?
    # clearTimeout(@games[table_name].timer)
    # delete @games[table_name].timer
    # @games[table_name].countdown = null

    # @games[table_name].dealer.hand = []
    # # util.debug("looping through players for cleanup")
    # for own username, player of @games[table_name].players
    #   util.debug(username, JSON.stringify(player), typeof username, typeof player)
    #   @games[table_name].hands[username] = []
    #   # util.debug("reset hands for that user")
    #   @games[table_name].players[username].action = null
    #   # util.debug("reset action for that user")
    # @games[table_name].twiddling = []
    # @games[table_name].hand_in_progress = false
    # util.debug("hand concluded")
    # util.debug("===================================")
    # TODO: if singleplayer, emit signal so client knows to display Deal button
    # TODO: deal() on a setTimeout?
  
  # "Private" methods
  ## Gameplay::Hand handle outcomes
  _end: (table_name, username, outcome) ->
    # util.debug("_end(#{table_name}, #{username}, #{outcome}")
    bet = @games[table_name].players[username].bet
    @games[table_name].players[username].purse += @rules.player_reward[outcome](bet)
    @games[table_name].twiddling.push(username)
    # util.debug("#{username}, #{outcome}, #{bet}")
  
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
    util.debug("_initial_deal(#{table_name})")
    for nametag in @games[table_name].seats
      username = @games[table_name].players[nametag].username
      util.debug("#{username}.action = #{@games[table_name].players[nametag].action}")

      twiddling_p = username in @games[table_name].twiddling
      idle_p = username in @games[table_name].idle
      stand_p = @games[table_name].players[username].action == "stand"

      if twiddling_p or idle_p or stand_p
      # if not @_in_play(table_name, player_uuid)
        util.debug("skipping #{username}")
        continue
      else
        util.debug("dealing card to #{username}")
        @games[table_name].hands[username] ?= []
        @games[table_name].hands[username].push(@games[table_name].deck.pop())
    
    dealer_value = @_hand_value(@games[table_name].dealer.hand)
    if @rules.dealer.should_hit(dealer_value)
      @games[table_name].dealer.hand.push(@games[table_name].deck.pop())
      util.debug("dealer hits @ #{dealer_value}")
    else
      util.debug("dealer stands @ #{dealer_value}")
  
  ## Gameplay conditionals
  _single_player: (table_name) ->
    return @games[table_name].seats.length == 1
  
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
    @games[table_name].players[user.username].bet = amount
    @games[table_name].players[user.username].purse -= amount # TODO: adjust to compensate
  
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
  
  _idle_user: (table_name, user, unseat = false) ->
    idle = @games[table_name].idle
    @games[table_name].idle.push(user.username)
    @_unseat_user(table_name, user) if unseat
  
  _deidle_user: (table_name, user) ->
    index = @games[table_name].idle.indexOf(user.username)
    if index >= 0
      delete @games[table_name].idle[index]
      @games[table_name].idle = @games[table_name].idle.filter(stripUndefineds)
  
  _seat_user: (table_name, user) ->
    @games[table_name].seats.append(user.username) if user.username not in @games[table_name].seats

  _unseat_user: (table_name, user) ->
    index = @games[table_name].seats.indexOf(user.username)
    if index >= 0
      delete @games[table_name].seats[index]
      @games[table_name].seats = @games[table_name].seats.filter(stripUndefineds)
  

  
  
    
module.exports = Dealer