_ = require("underscore")
async = require("async")
EventEmitter = require("events").EventEmitter

Random = require("../../lib/alea")()
words = {}
{words.adj, words.nouns} = require("../../lib/username-words")
words.ints = [0..99]

class Dealer extends EventEmitter
  constructor: (@_Manager) ->
    # TODO: load default rules & deck(s)
    @games = {}
    @listeners = {}
    @create(name, meta) for own name, meta of @_Manager.tables
    @_Manager._register(@update)
  
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
    return callback("No such table found.") if not @games[table_name]?
    return callback("Invalid user supplied") if not user.username? # TODO: expand into @validate_user()?

    try # defensive programming
      username = user.username
      @games[table_name].seats.push(username)
      @games[table_name].players[username] = user # FUTURE: slightly redundant w/ username twice
      @listeners[username] = on_update
      @on(username, on_update)
    catch error
      return callback(error, null)
    
    callback(null, @games[name])

  remove_player: (table_name, username, callback) ->
    return callback("No such table found.") if not @games[table_name]?
    return callback("Username must not be blank") if not username or username == ""

    # TODO: if hand_in_progress then release bet or something?
    seats = @games[table_name].seats
    index = seats.indexOf(username)
    delete seats[index]
    seats = seats.filter((d) -> typeof d != "undefined") # Table sizes are small so O(n) is no biggie

    delete @games[table_name].players[username]
    @removeListener(@listeners[username])
    delete @listeners[username]


class Manager extends EventEmitter
  constructor: (@max_tables = 5) ->
    @tables = {}
    @players = {}
    @names = {} # TODO: Could get quite large
    @create("Table #{i}") for i in [0..@max_tables-1]
  
  # "Data" API
  _default: (name) -> 
    # Note: if you add to this, keys must be shallow (1 deep)
    return {
      players: [0, 6],
      betrange: [10, 100],
      private: null
    }

  _randindex: (len) -> return Math.floor(Random() * (len - 1))
  
  _name: (name = null) ->
    tries = 0
    while (not name or name in @names)
      name = [
        words.adj[@_randindex(words.adj.length)],
        words.nouns[@_randindex(words.nouns.length)],
        words.ints[@_randindex(words.ints.length)]
      ].join("-")
      tries++
      throw "name generation returned invalid result" if name == "" or name = "--" or tries >= 25
    return name

  _new_player: (name = @_name()) ->
    return {
      name: name,
      purse: 500
    }

  # "Public" API
  create: (name, options = {}) ->
    @tables[name] = @_default(name)
    @emit("_create", @tables[name])
  
  listen: (clientId, callback) ->
    callback(null, @tables)
    @listeners[clientId] = callback
    @.on("_create", callback)
  
  unlisten: (clientId) -> @removeListener("create", @listeners[clientId])

  sit: (table_name, user, callback) ->
    # TODO: handle if user is already seated
    # TODO: check if table is full or private
    # TODO: Dealer:: fill seat & get table data
    # TODO: callback(err, data) where data = table state

  leave: (table_name, user, callback) ->
    @tables[table_name]

  # "Private" API
  _register: (callback) ->
    # Used by Dealer to update table data based on Manager's changes
    @.on("update", callback)

  _already_seated: (user) ->


module.exports = (nowjs, nitrous, app) ->
  subscribe = app.redis.subscribe
  publish = app.redis.publish 

  everyone = nowjs.initialize(app, {socketio: {transports:['websocket', 'xhr-polling','jsonp-polling']}})

  Lobby = new Manager()
  Bernie = new Dealer(Games)
  
  ## Nowjs User Functions
  everyone.now.listen_tables = () ->
    client = this
    Lobby.listen(client.user.clientId, client.now.show_tables)

  everyone.now.sit_down = (name) ->
    client = this
    client.room = name
    Lobby.unlisten(client.user.clientId)
    Lobby.sit(name, this.player, client.load_game)

  everyone.now.stand_up = (name) ->
    client = this
    client.room = "Lobby"
    Lobby.listen(client.user.clientId, client.now.show_tables)

  everyone.now.perform_action = (name, user, data, callback) ->
    # TODO: 
  
  everyone.now.test_poke = (callback) ->
    console.log(Bernie.games)
    callback(Bernie.games)
  

  ## Nowjs Event Listeners
  nowjs.on("connect", () ->
    client = this
    client.room ?= "Lobby"

    sid = decodeURIComponent(client.user.cookie["connect.sid"])
    app.session_store.get(sid, (err, session) ->
      throw err if err

      console.log("session:")
      console.log(session)

      client.player = session.blackjack || Lobby._new_player()
      app.session_store.set(sid, session, () ->)
    )
  )

  nowjs.on("disconnect", () ->
    # TODO: clean up all connections & listeners
    Games.unlisten(this.user.clientId)
  )

  
  
  return everyone