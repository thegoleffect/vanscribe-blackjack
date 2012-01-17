_ = require("underscore")
$ = require("jquery")
Deck = require("./deck")
EE = require("../common/ee")

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
    hand: {
      is_bust: (count) ->
        return count > 21
    },
    dealer: {
      should_hit: (count) ->
        return count < 17
      should_shuffle: (D) ->
        return D.cards_remaining() <= Math.floor(.25 * D.cards_total())
    },
    player_reward: {
      blackjack: (bet) -> return Math.floor(1.5*bet)
      push: (bet) -> return bet
      win: (bet) -> return 2*bet
      lose: (bet) -> return -bet
    }
    use_hole: false,
  }

  constructor: (@_tables, @ruleset = {}) ->
    # TODO: load default rules & deck(s)
    @rules = $.extend(true, {}, @default_rules, @ruleset)
    @decks = new Deck(@rules.decks)
    @games = {}
    @listeners = {}
    @create(name, meta) for own name, meta of @_tables

  update: (err, data, callback) ->
    console.log("updated called")
    console.log(arguments)

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
    @games[name] = {
      meta: meta,
      hand_in_progress: false,
      pot: 0,
      seats: [],
      players: {},
      hands: {},
      dealer: {
        hand: []
      },
      queued: [], # sat down while hand_in_progress, will be seated next hand
      outlist: [], # locked out of game until place bet
      twiddling: [],
      countdown: null
    }
    # @emit("_create", @games[name])
  
  add_player: (table_name, user, on_update, callback) ->
    return callback("No such table found.") if not @games[table_name]?
    return callback("Invalid user supplied") if not user?.username? # TODO: expand into @validate_user()?
    
    username = user.username
    if @games[table_name].hand_in_progress
      @games[table].queued.push(username)
    else
      @games[table_name].seats.push(username)
      @games[table_name].players[username] = user # FUTURE: slightly redundant w/ username twice
    
    @emit(@_signal(table_name), null, {
      username: username,
      action: "joined",
      ts: +new Date()
    })
    @on(@_signal(table_name), on_update)
    @sanitize(table_name, callback)
  
  remove_player: (table_name, user, callback) ->
    # console.log("remove_player(#{table_name}, #{user.username}, callback)")
    # console.log("Dealer.remove_player should have @games: #{@games?}")
    # console.log("_.keys(@games).length should be non-zero: " + _.keys(@games).length)

    return callback("No such table found.") if not @games[table_name]?
    return callback("Invalid user supplied") if not user?.username?
    return callback("Username should be a string") if typeof user.username != "string"
    return callback("Username must not be blank") if user.username == ""
    # console.log("after remove_player error checkers")

    # TODO: if hand_in_progress then release bet or something?
    username = user.username 
    seats = @games[table_name].seats
    index = seats.indexOf(username)
    delete seats[index]
    seats = seats.filter((d) -> typeof d != "undefined") # Table sizes are small so O(n) is no biggie
    delete @games[table_name].players[username]

    # if @listeners[username]?
    #   console.log("this.games.length = #{@games.length}")
    #   console.log("listener for #{username}")
    #   console.log(@listeners[username].toString())
    #   @removeListener(@listeners[username])
    #   delete @listeners[username]
    
    callback(null, true)
  
  sanitize: (table_name, callback) ->
    d = _.clone(@games[table_name])
    delete d.hands
    callback(null, d)
  
  place_bet: (table_name, user, amount, callback, err = null) ->
    return callback("Bet cannot be more than the maximum (100)") if amount > @rules.bet.max
    return callback("Bet cannot be less than the minimum (10)") if amount < @rules.bet.min
    
    if @games[table_name].hand_in_progress
      if user.username in @games[table_name].queued
        @_set_bet(table_name, user, amount)
        return callback(err, amount)
    
    if @games[table_name].seats.length == 1
      @_set_bet(table_name, user, amount)
      @deal(table_name)
      return callback(err, amount)
    else
      # TODO: fix this logic
      if amount == 0
        @_queue_user(table_name, user)
        @_set_bet(table_name, user, amount)
        return callback(err, amount)
    
    return callback("Bet cannot be changed during hand.")
  
  get_hands: (table_name, user, callback) ->
    hands = {
      dealer: @get_dealer_hand(table_name)
    }
    hands[user.username] = @_get_player_hand(table_name, user)
    return hands

  get_dealer_hand: (table_name) ->
    return @games[table_name].dealer.hand
  
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

    if @rules.dealer.should_shuffle(@decks)
      @emit(@_signal(table_name), null, {
        username: "Dealer",
        action: "shuffling",
        ts: +new Date()
      })
      @decks.shuffle()
    
    # deal out cards mimicking real dealer
    @_deal()
    @_deal()

    @emit(@_signal(table_name), null, {
      username: "Dealer",
      action: "dealt",
      ts: +new Date()
    })

    # TODO: check for one or more blackjacks
    over = @evaluate(table_name)
    if not over
      # If users haven't responded by @rules.countdown, then they stand
      self = this
      @games[table_name].countdown = new Date((+new Date()) + @rules.countdown)
      @games[table_name].timer = setTimeout((() ->
        self.force_evaluate(table_name)
      ), @rules.countdown)
    else
      @finish_hand(table_name)
  
  perform_action: (table_name, user, action, callback) ->
    switch action
      when "hit"
        @hit(table_name, user)
      when "stand"
        @stand(table_name, user)
      else 
        return callback("Unauthorized action performed (#{action})")
    
    if not @_waiting()
      @force_decisions(table_name, callback)
    else
      @games[table_name].twiddling.push(user.username)
      # TODO: emit signal to indicate ready check
  
  force_evaluate: (table_name, callback = () ->) ->
    @games[table_name].timer = null
    @games[table_name].countdown = null
    # TODO: 
  
  evaluate: (table_name) ->
    # dealer_value = 
    # for own username, hand of @games[table_name].hands

  finish_hand: (table_name) ->
    @games[table_name].dealer.hand = []
    for own username, player of @games[table_name].players
      player.hand = []
    @games[table_name].twiddling = []
    @games[table_name].hand_in_progress = true
  
  # "Private" methods
  _get_player_hand: (table_name, user) ->
    return @games[table_name].hands[user.username]
  
  _reward: (table_name, user, status) ->
    throw "Invalid outcome passed to Dealer._reward" if not @rules.player_reward[status]?

    wager = @games[table_name].players[user.username].bet
    @games[table_name].players[user.username].purse += @rules.player_reward[status](wager)
    # TODO: emit?

  _set_bet: (table_name, user, amount) ->
    @games[table_name].players[user.username].bet = amount
  
  _queue_user: (table_name, user) ->
    seats = @games[table_name].seats

    @games[table_name].queued.push(user.username)

    index = seats.indexOf(user.username)
    if index >= 0
      delete seats[index]
      seats[index] = seats[index].filter((d) -> return typeof d != "undefined")
  
  _dequeue_user: (user) ->
    queue = @games[table_name].queued
    for u, i in queue
      if u.username != user.username
        continue
      else
        delete queue[i]
        queue = queue.filter((d) -> return typeof d != "undefined")
        break
  
  _in_play: (table_name, username) ->
    return false if username in @games[table_name].outlist
    return true
  
  _deal: (table_name) ->
    for i in @games[table_name].seats
      player_uuid = @games[table_name].players[i]
      if not @_in_play(table_name, player_uuid)
        continue
      else
        @table.hands[player_uuid].push(@deck.pop())
    @table.dealer_hand.push(@deck.pop())
  
  _hand_value: (h) ->
    



module.exports = Dealer