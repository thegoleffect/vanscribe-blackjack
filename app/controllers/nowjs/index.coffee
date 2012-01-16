_ = require("underscore")
async = require("async")
EventEmitter = require("events").EventEmitter

class Dealer
  constructor: (rooms = 5) ->


class Manager extends EventEmitter
  constructor: (@max = 5) ->
    @tables = {}
    @players = {}
    @create("Table #{i}") for i in [0..@max-1]
  
  # "Data" API
  _default: (name) -> 
    # Note: if you add to this, keys must be shallow (1 deep)
    return {
      name: name,
      players: [0, 6],
      betrange: [10, 100],
      private: null
    }
  _new_player: (name) ->
    return {
      name: name,
      purse: 500
    }

  # "Public" API
  create: (name, options = {}) ->
    @tables[name] = @_default(name)
    @emit("create", @tables[name])
  
  listen: (clientId, callback) ->
    callback(null, @tables)
    @listeners[clientId] = callback
    @.on("create", callback)
  
  unlisten: (clientId) -> @removeListener("create", @listeners[clientId])

  sit: (table_name, user, callback) ->
    # TODO: handle if user is already seated
    # TODO: check if table is full or private
    # TODO: callback(err, data) where data = table state


  leave: (table_name, user, callback) ->
    @tables[table_name]

  # "Private" API
  

  _already_seated: (user) ->




    



module.exports = (nowjs, nitrous, app) ->
  subscribe = app.redis.subscribe
  publish = app.redis.publish 

  everyone = nowjs.initialize(app, {socketio: {transports:['websocket', 'xhr-polling','jsonp-polling']}})
  
  ## Nowjs User Functions
  Games = new Manager()

  everyone.now.listen_tables = () ->
    console.log("listen_tables() called")
    client = this.now
    Games.listen(this.user.clientId, client.show_tables)

  everyone.now.sit_down = (name) ->
    client = this.now
    Games.sit(name, this.player, client.load_game)
  

  ## Nowjs Event Listeners
  nowjs.on("connect", () ->
    now = this
    user = now.user
    now.room ?= "Public"

    sid = decodeURIComponent(this.user.cookie["connect.sid"])
    app.session_store.get(sid, (err, session) ->
      throw err if err

      console.log("session:")
      console.log(session)
      now.player = session.blackjack || Games._new_player()
    )
  )

  nowjs.on("disconnect", () ->
    # TODO: clean up connections
    Games.unlisten(this.user.clientId)
  )

  
  
  return everyone