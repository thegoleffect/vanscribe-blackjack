_ = require("underscore")
async = require("async")
# EventEmitter = require("events").EventEmitter
util = require('util')

Dealer = require("../../models/blackjack/dealer")
EE = require("../../models/common/ee")
Manager = require("../../models/blackjack/manager")

stripNowjs = (obj) ->
  if typeof obj != 'object'
    throw "Can't stripNowjs on a #{typeof obj}"
  else
    clone = {}
    for own key, value of obj
      clone[key] = value
  return clone


module.exports = (nowjs, nitrous, app) ->
  subscribe = app.redis.subscribe
  publish = app.redis.publish
  console.log("nitrous: ")
  # console.log(app.config(app))
  console.log(nitrous.settings)
  everyone = nowjs.initialize(app, {socketio: nitrous.settings.socketio})

  Lobby = new Manager()
  Bernie = new Dealer(Lobby.tables)

  Lobby.on(Lobby._signal("update"), (err, data, callback) ->
    Bernie.update(err, data, callback)
  )
  
  ## Nowjs User Functions
  ## TODO: namespace the functions somehow
  everyone.now.room = (callback = null) ->
    client = this
    util.debug("client requested room name: #{client.now.room}")
    callback(client.now.room) if callback?
  
  everyone.now.sendChat = (message) ->
    client = this
    nowjs.getGroup(client.now.room).now.receiveChat(client.now.player.username, message, +new Date())
  
  # everyone.now.get_tables_listSync = () -> 

  everyone.now.get_tables_list = (callback = null) ->
    # Usage: now.tables_list(function(){ util.debug(arguments); })
    client = this
    return Lobby.list(callback)
  
  # everyone.now.tables_listen = (callback = null) ->
  #   client = this
  #   # Lobby.listen(client.user.clientId, client.now.show_tables)
  #   # callback(null) if callback?
  #   callback("this function is deprecated") if callback?
  #   # return "deprecated"
  
  everyone.now.sit_down = (name) ->
    client = this
    client.now.room = name
    # util.debug("about to Lobby.sit()")
    Lobby.sit(name, stripNowjs(client.now.player), client.now.receive_action, client.now.load_game)
  
  everyone.now.stand_up = (callback = null) ->
    client = this
    # TODO: Dealer.cash out?

    Lobby.leave(client.now.room, client.now.player, (err, tables) ->
      throw err if err

      # TODO: factor out into separate fn
      nowjs.getGroup(client.now.room).removeUser(client.user.clientId)
      client.now.room = "Lobby"
      nowjs.getGroup(client.now.room).addUser(client.user.clientId)

      callback(null, tables) if callback?
    )
  
  ## Gameplay related functions
  everyone.now.bet = (amount, callback) ->
    client = this
    Bernie.place_bet(client.now.room, stripNowjs(client.now.player), amount, callback)
  
  everyone.now.get_table = (callback = () -> ) ->
    client = this
    return Bernie.sanitize(client.now.room, callback)
  
  everyone.now.get_purse = () ->
    return Bernie.get_purse(client.now.room, stripNowjs(client.now.player))

  everyone.now.hit = (callback = () ->) ->
    client = this
    return Bernie.request_action(client.now.room, stripNowjs(client.now.player), "hit")
  
  everyone.now.stand = (callback = () ->) -> 
    client = this
    Bernie.request_action(client.now.room, stripNowjs(client.now.player), "stand")

  everyone.now.deal = (callback = () ->) ->
    # Usage: now.deal()
    client = this
    Bernie.request_action(client.now.room, stripNowjs(client.now.player), "deal", callback)
    
  ## Development related functions (for testing stuff) TODO: delete these
  everyone.now.test_poke = (callback) ->
    # Usage: now.test_poke(function(){ console.log(arguments); }) or games = now.test_poke()
    callback(Bernie.games)

  everyone.now.inspect = (callback) ->
    callback({Lobby: Lobby, Dealer: Bernie})
  

  ## Nowjs Event Listeners
  nowjs.on("connect", () ->
    # TODO: give client a version #
    client = this
    client.now.room ?= "Lobby"
    nowjs.getGroup(client.now.room).addUser(client.user.clientId)

    # util.debug("just connected: client.now.player: ")
    # util.debug(JSON.stringify(client.now.player))

    # TODO: use updated nowjs session
    sid = decodeURIComponent(client.user.cookie["connect.sid"])
    util.debug("#{this.user.clientId} connected")
    # TODO: log the connection
    app.session_store.get(sid, (err, session) ->
      throw err if err

      # util.debug("session for sid ('#{sid}''):")
      # util.debug(JSON.stringify(session))

      if session.blackjack?
        # TODO: auth user
        # util.debug("before setting from session.blackjack")
        # util.debug(JSON.stringify(client.now.player))
        # util.debug("======================")
        # util.debug("session.blackjack to json")
        # util.debug(JSON.stringify(session.blackjack))
        
        # client.now.player = session.blackjack
        if not client.now.player?
          client.now.player = {}
          client.now.player["username"] = session.blackjack.username if session.blackjack.username?
          client.now.player["purse"] = session.blackjack.purse if session.blackjack.purse?
        else
          # TODO: verify match
          verified = true
          for own key, val in session.blackjack
            if client.now.player[key] != val
              verified = false
          # util.debug("FYI: client reconnected w/ existing data that matches session data")

        # util.debug("before Lobby.sign_in(): ")
        # util.debug(JSON.stringify(client.now.player))
        Lobby.sign_in(client.now.player)
        # util.debug("after signin:")
        # util.debug(JSON.stringify(client.now.player))
      else
        session.blackjack = client.now.player = Lobby.join()
        # util.debug("Lobby.join(): ")
        # util.debug(JSON.stringify(session.blackjack))
        app.session_store.set(sid, session, () ->)
    )
  )

  nowjs.on("disconnect", () ->
    # TODO: clean up all connections & listeners
    client = this
    Lobby.leave(client.now.room, client.now.player, (err, tables) ->)
  )

  
  
  return everyone