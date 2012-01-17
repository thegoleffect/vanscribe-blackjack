_ = require("underscore")
async = require("async")
EventEmitter = require("events").EventEmitter
util = require('util')

Random = require("../../lib/alea")()
{adjectives, nouns, ints} = require("../../lib/username-words")

class EE extends EventEmitter
  _signal: (name) ->
    throw "Must set @signal prefix on descendant class" if not @signal?
    return [@signal, name].join("::")

class Dealer extends EE
  signal: "dealer"
  constructor: (@_tables) ->
    # TODO: load default rules & deck(s)
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
      dealer: {
        hand: []
      }
    }
    # @emit("_create", @games[name])
  
  add_player: (table_name, user, on_update, callback) ->
    console.log("add_player()")
    console.log(arguments)
    console.log("Dealer.add_player should have @games: #{@games?}")
    return callback("No such table found.") if not @games[table_name]?
    return callback("Invalid user supplied") if not user?.username? # TODO: expand into @validate_user()?

    console.log("about to do try/catch block")
    try # defensive programming
      username = user.username
      @games[table_name].seats.push(username)
      @games[table_name].players[username] = user # FUTURE: slightly redundant w/ username twice
      # @listeners[username] = on_update
      # @on(username, on_update) # TODO: use @_signal or nah?
    catch error
      throw error
    console.log("after try/catch")
    @sanitize(table_name, callback)
  
  remove_player: (table_name, user, callback) ->
    console.log("remove_player(#{table_name}, #{user.username}, callback)")
    console.log("Dealer.remove_player should have @games: #{@games?}")
    console.log("@games.length should be non-zero: " + @games.length)

    cb = callback
    callback = (msg) ->
      throw (msg)
    
    return callback("No such table found.") if not @games[table_name]?
    return callback("Invalid user supplied") if not user?.username?
    return callback("Username should be a string") if typeof user.username != "string"
    return callback("Username must not be blank") if user.username == ""
    console.log("after remove_player error checkers")
    callback = cb

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
    callback(null, d)


class Manager extends EE
  signal: "tables"
  constructor: (@max_tables = 5) ->
    @tables = {}
    @members = {}
    @names = {} # TODO: Could get quite large
    # @dealer = null

    @create("Table #{i}") for i in [0..@max_tables-1]
  
  # "Data" API
  _default: (options = {}) -> 
    # Note: if you add to this, keys must be shallow (1 deep)
    base = {
      players: [],
      max_players: 6,
      betrange: [10, 100],
      private: null
    }
    base.private = options.private if options.private?
    base.max_players = options.max_players if options.max_players?
    # base.betrange = options.betrange if options.betrange? # FUTURE: let players adj this?
    return base

  _randindex: (len) -> return Math.floor(Random() * (len - 1))
  
  _name: (name = null) ->
    tries = 0
    while (not name or name in @names)
      name = [
        adjectives[@_randindex(adjectives.length)],
        nouns[@_randindex(nouns.length)],
        ints[@_randindex(ints.length)]
      ].join("-")
      tries++
      throw "name generation returned invalid result (#{name})" if name == "" or name == "--" or tries >= 25
    return name

  _new_player: (name = @_name()) ->
    return {
      username: name,
      purse: 500
    }

  # "Public" API
  join: () ->
    members_card = @_new_player()
    @members[members_card.username] = 1
    return members_card
  
  sign_in: (members_card) ->
    @members[members_card.username] = 1
    return members_card

  create: (name, options = {}) ->
    @tables[name] = @_default()
    @emit(@_signal("update"), null, {
      type: "create"
    }, () -> ) # FUTURE: move to a delta signal

  employ: (dlr) ->
    # @dealer = dlr
    @_register(dlr.update)

  list: (callback = null) -> callback(null, @tables) if callback
  
  listen: (clientId, callback) ->
    callback(null, @tables)
    @listeners[clientId] = callback
    @on(@_signal('update'), callback)
  
  unlisten: (clientId) ->
    @removeListener(@_signal('update'), @listeners[clientId])

  sit: (table_name, user, onUpdate, callback) ->
    console.log("about to sit() error check")
    return callback("Table '#{table_name}' was not found") if not @tables[table_name]?
    return callback("You are already seated here") if @_already_seated_here(table_name, user)
    return callback("Table is full") if @_already_full(table_name)
    return callback("User must exist & have username") if not user or not user.username
    return callback("User must register by join()") if user.username not in _.keys(@members)
    # return callback("Table is private") # TODO: 
    console.log("sit error checkers")

    @tables[table_name].players.push(user.username)
    s = @_signal('update')
    console.log("about to emit(#{s}) ")
    @emit(@_signal("update"), null, {
      action: "sit",
      table_name: table_name
      user: user,
      onUpdate: onUpdate
    }, callback)
    console.log("emit'd")

    # @dealer.add_player(table_name, user, onUpdate, (err, state) ->
    #   return callback(err) if err
    #   self.emit(self._signal("update"), self.tables)

    #   callback(null, state)
    # )

  leave: (table_name, user, callback) ->
    console.log("inside Lobby.leave(#{table_name})")
    return callback("Invalid table name supplied (#{table_name})") if not @tables[table_name]?
    return callback("User must exist & have username") if not user or not user.username
    return callback("User must register by join()") if user.username not in _.keys(@members)
    return callback("Cannot stand up unless already seated.") if not @_already_seated_here(table_name, user)
    console.log("after leave's error checking")
    # Note: if hand in progress and player has bet => it is forfeit

    index = @tables[table_name].players.indexOf(user.username)
    console.log("index of user = #{index}")
    delete @tables[table_name].players[index]
    console.log("=========")
    console.log("contents of @tables[#{table_name}].players: ")
    console.log(@tables[table_name].players)
    console.log("=========")
    @tables[table_name].players = @tables[table_name].players.filter((d) -> typeof d != "undefined")
    console.log("removed player from manager? " + (user.username not in @tables[table_name].players))

    @emit(@_signal("update"), null, {
      action: "stand",
      table_name: table_name
      user: user
    }, callback)
    # @dealer.remove_player(table_name, user, (err, status) ->
    #   console.log("should have removed player from dealer")
    #   return callback(err) if err

    #   self.emit(self._signal("update"), self.tables)
    #   callback(null, self.tables)
    # )

  # "Private" API
  # _register: (callback) ->
  #   # Used by Dealer to update table data based on Manager's changes
  #   @on(@_signal("update"), callback)
  #   @on(@_signal("update"), () ->
  #     console.log("tables::update detected:")
  #     console.log(arguments)
  #   )

  _already_seated_here: (table_name, user) ->
    # FUTURE: change to a more optimal data structure w/ distributed version
    return true if user.username in @tables[table_name].players 
    return false
  
  _already_full: (table_name) ->
    t = @tables[table_name]
    return true if t.players.length == (t.max_players - 1)
    return false


module.exports = (nowjs, nitrous, app) ->
  subscribe = app.redis.subscribe
  publish = app.redis.publish
  everyone = nowjs.initialize(app, {socketio: {transports:['websocket', 'xhr-polling','jsonp-polling']}})

  Lobby = new Manager()
  Bernie = new Dealer(Lobby.tables)

  Lobby.on(Lobby._signal("update"), (err, data, callback) ->
    Bernie.update(err, data, callback)
  )
  
  ## Nowjs User Functions
  everyone.now.table = (callback = null) ->
    client = this
    console.log("client requested room name: #{client.room}")
    callback(client.room) if callback?

  everyone.now.list_tables = (callback = null) ->
    client = this
    Lobby.list(callback)
  
  everyone.now.listen_tables = (callback = null) ->
    client = this
    # Lobby.listen(client.user.clientId, client.now.show_tables)
    callback(null) if callback?

  everyone.now.sit_down = (name) ->
    client = this
    client.now.room = name
    # Lobby.unlisten(client.user.clientId)
    console.log("about to Lobby.sit()")
    Lobby.sit(name, client.now.player, client.now.receive_action, client.now.load_game)

  everyone.now.stand_up = () ->
    client = this
    Lobby.leave(client.now.room, client.now.player, (err, tables) ->
      throw err if err
      client.now.room = "Lobby"
      # Lobby.listen(client.user.clientId, client.now.show_tables)
    )

  everyone.now.perform_action = (name, user, data, callback) ->
    # TODO: 
  
  everyone.now.test_poke = (callback) ->
    # console.log(Bernie.games)
    callback(Bernie.games)

  everyone.now.inspect = (callback) ->
    callback({Lobby: Lobby, Dealer: Bernie})
  

  ## Nowjs Event Listeners
  nowjs.on("connect", () ->
    client = this
    # console.log("client room: #{client.room}")
    # client.room ?= "Lobby"
    # console.log("client room: #{client.room}")
    client.now.room ?= "Lobby"
    nowjs.getGroup(client.now.room).addUser(client.user.clientId)


    sid = decodeURIComponent(client.user.cookie["connect.sid"])
    app.session_store.get(sid, (err, session) ->
      throw err if err

      console.log("session for sid (#{sid}):")
      console.log(session)

      if session.blackjack?
        # TODO: auth user
        client.now.player = session.blackjack
        Lobby.sign_in(client.now.player)
      else
        session.blackjack = client.now.player = Lobby.join()
        app.session_store.set(sid, session, () ->)
    )
  )

  nowjs.on("disconnect", () ->
    # TODO: clean up all connections & listeners
    client = this
    # Lobby.unlisten(client.user.clientId)
  )

  
  
  return everyone