_ = require("underscore")
$ = require("jquery")
CardFactory = require("./cardfactory")
Deck = require("./deck")
EE = require("../common/ee")

stripUndefineds = (d) -> return typeof d != "undefined"

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
      @games[table_name].players[username] = user # FUTURE: slightly redundant w/ username twice
      @games[table_name].hands[username] = []
    
    @emit(@_signal(table_name), null, {
      username: username,
      action: "joined",
      ts: +new Date()
    })
    @on(@_signal(table_name), on_update)
    @sanitize(table_name, callback)
  
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
    #   console.log("this.games.length = #{@games.length}")
    #   console.log("listener for #{username}")
    #   console.log(@listeners[username].toString())
    #   @removeListener(@listeners[username])
    #   delete @listeners[username]
    
    callback(null, true)
  
  sanitize: (table_name, callback) ->
    # TODO: dbl check if have to adjust this
    d = _.clone(@games[table_name])
    delete d.hands
    callback(null, d)
  
  place_bet: (table_name, user, amount, callback) ->
    return callback("Bet cannot be more than the maximum (100)") if amount > @rules.bet.max
    return callback("Bet cannot be less than the minimum (10)") if amount < @rules.bet.min
    
    ineligible = @_can_set_bet(table_name, user)
    if ineligible
      return callback(ineligible)
    else
      @_set_bet(table_name, user, amount)
    
    # return
    # # TODO: activate player if idle
    # if @games[table_name].hand_in_progress
    #   if user.username in @games[table_name].queued
    #     @_set_bet(table_name, user, amount)
    #     return callback(null, amount)
    
    # if @games[table_name].seats.length == 1
    #   @_set_bet(table_name, user, amount)
    #   @deal(table_name)
    #   return callback(err, amount)
    # else
    #   # TODO: fix this logic
    #   if amount == 0
    #     @_queue_user(table_name, user)
    #     @_set_bet(table_name, user, amount)
    #     return callback(err, amount)
    # return callback("Bet cannot be changed during hand.")
  
  get_hands: (table_name, user, callback) ->
    return callback("You are not currently sitting at #{table_name}") if user.username not in _.keys(@games[table_name].players)
    self = this
    hands = {
      dealer: @get_dealer_hand(table_name)
    }
    if @games[table_name].hand_in_progress
      hands[user.username] = @_get_player_hand(table_name, user)
    else
      for own username, hand of @games[table_name].hands
        hands[username] = @games[table_name].hands[username].map((c) ->
          card = self.games[table_name].deck.CF.identify(c)
          return card
        )
    
    callback(null, hands)

  get_dealer_hand: (table_name) ->
    cards = []
    for card in @games[table_name].dealer.hand
      cards.push(@games[table_name].deck.CF.identify(card))
    return cards
  
  # TODO: replace @games[table_name] w/ shorthand, to eliminate multiple lookups
  deal: (table_name) ->
    throw "No such table exists" if not @games[table_name]?
    @games[table_name].hand_in_progress = true

    # Bring Queued players in
    for u in @games[table_name].queued
      @games[table_name].seats.push(u.username)
      @games[table_name].players[u.username] = u
      @_dequeue_user(u)
    
    # Pull out Idle players
    for own username, player of @games[table_name].players
      console.log(username, player)
      if not player.bet?
        @_idle_user(table_name, player)

    if @rules.dealer.should_shuffle(@games[table_name].deck)
      @emit(@_signal(table_name), null, {
        username: "Dealer",
        action: "shuffling",
        ts: +new Date()
      })
      @games[table_name].deck.shuffle()
    
    # deal out cards mimicking real dealer
    @_deal(table_name)
    @_deal(table_name)

    @emit(@_signal(table_name), null, {
      username: "Dealer",
      action: "dealt",
      ts: +new Date()
    })

    # TODO: check for one or more blackjacks
    over = @evaluate(table_name)
    console.log("evaluate response = #{over}")
    if not over
      # If users haven't responded by @rules.countdown, then they stand & are moved to idle
      self = this
      @games[table_name].countdown = new Date((+new Date()) + @rules.countdown)
      @games[table_name].timer = setTimeout((() ->
        self.force_evaluate(table_name)
      ), @rules.countdown)
    else
      @finish_hand(table_name)

  perform_action: (table_name, user, action) ->
    switch action
      when "hit", "stand"
        @games[table_name].players[user.username].action = action
      else 
        return callback("Unauthorized action performed (#{action})")
    
    if not @_waiting(table_name, user)
      @force_evaluate(table_name)
    else
      # Do nothing
      # TODO: emit signal to indicate ready check
  
  force_evaluate: (table_name, callback = () ->) ->
    @games[table_name].timer = null
    @games[table_name].countdown = null
    # TODO: perform all actions
    # TODO: handle inactive players
    # TODO: run @evaluate()
  
  evaluate: (table_name) ->
    console.log("evalute called()")
    throw "No such table found" if not @games[table_name]?

    console.log(@games[table_name].dealer)
    console.log(@games[table_name].hands)
    for own username, hand of @games[table_name].hands
      continue if username in @games[table_name].twiddling # skip players who are waiting
      continue if username in @games[table_name].idle
      console.log("evaluating #{username}")
      if @_is_bust(hand)
        @_lose(table_name, username) 
        continue
      else
        # TODO: missing logic for winning under 21 & dealer busts
        if @_is_blackjack(hand)
          if @_is_blackjack(@games[table_name].dealer.hand)
            @_push(table_name, username)
          else
            @_win_blackjack(table_name, username)
        else
          if @_is_blackjack(@games[table_name].dealer.hand)
            @_lose(table_name, username)
          else
            # player is still in play
            continue
    
    return @games[table_name].idle.length == (@games[table_name].seats.length + 1)

  finish_hand: (table_name) ->
    @games[table_name].dealer.hand = []
    for own username, player of @games[table_name].players
      player.hand = []
      player.action = null
    @games[table_name].twiddling = []
    @games[table_name].hand_in_progress = false
    # TODO: dequeue any Q'd players
  
  # "Private" methods
  _end: (table_name, username, outcome) ->
    bet = @games[table_name].players[username].bet
    @games[table_name].players[username].purse += @rules.player_reward["outcome"](bet)
    @games[table_name].twiddling.push(username)
    console.log("#{username}, #{outcome}, #{bet}")
  
  _lose: (table_name, username) -> @_end(table_name, username, "lose")

  _win: (table_name, username) -> @_end(table_name, username, "win")

  _win_blackjack: (table_name, username) -> @_end(table_name, username, "blackjack")
  
  _push: (table_name, username) -> @_end(table_name, username, "push")

  _is_blackjack: (hand) ->
    return false if hand.length > 2
    return false if @_hand_value(hand) != 21
    return true
  
  _is_bust: (hand) ->
    return true if @_hand_value(hand) > 21
    return false
  
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

  _get_player_hand: (table_name, user) ->
    self = this
    return @games[table_name].hands[user.username].map((c) ->
      card = self.games[table_name].deck.CF.identify(c)
      return card
    )
  
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
  
  _set_bet: (table_name, user, amount) ->
    @games[table_name].players[user.username].bet = amount
  
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
  
  _waiting: (table_name, user) ->
    return true if @games[table_name].seats.length == 1 

    for username, player in @games[table_name].players
      if player.action == null
        return false
    return true

  _in_play: (table_name, username) ->
    return false if username in @games[table_name].twiddling
    return false if username in @games[table_name].idle
    return false if @games[table_name].players[username].action == "stand"
    return true
  
  _deal: (table_name) ->
    for i in @games[table_name].seats
      player_uuid = @games[table_name].players[i].username
      if not @_in_play(table_name, player_uuid)
        continue
      else
        @games[table_name].hands[player_uuid] ?= []
        @games[table_name].hands[player_uuid].push(@games[table_name].deck.pop())
    @games[table_name].dealer.hand.push(@games[table_name].deck.pop()) if @rules.dealer.should_hit(@_hand_value(@games[table_name].dealer.hand))
    
module.exports = Dealer