_ = require("underscore")
async = require("async")
# EventEmitter = require("events").EventEmitter
util = require('util')

Dealer = require("../../models/blackjack/dealer")
EE = require("../../models/common/ee")
Manager = require("../../models/blackjack/manager")

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
  ## TODO: namespace the functions somehow
  everyone.now.room = (callback = null) ->
    client = this
    console.log("client requested room name: #{client.now.room}")
    callback(client.now.room) if callback?
  
  everyone.now.sendChat = (message) ->
    client = this
    nowjs.getGroup(client.now.room).now.receiveChat(client.now.player.username, message, +new Date())
  
  # everyone.now.tables_listSync = () -> 

  everyone.now.tables_list = (callback = null) ->
    client = this
    Lobby.list(callback)
  
  everyone.now.tables_listen = (callback = null) ->
    client = this
    # Lobby.listen(client.user.clientId, client.now.show_tables)
    # callback(null) if callback?
    callback("this function is deprecated") if callback?
    # return "deprecated"
  
  everyone.now.sit_down = (name) ->
    client = this
    client.now.room = name
    # Lobby.unlisten(client.user.clientId)
    console.log("about to Lobby.sit()")
    Lobby.sit(name, client.now.player, client.now.receive_action, client.now.load_game)
    # Bernie.ack(name, client.now.player, client.now.receive_action)
  
  everyone.now.stand_up = (callback = null) ->
    client = this
    # TODO: Dealer.cash out?
    Lobby.leave(client.now.room, client.now.player, (err, tables) ->
      throw err if err
      client.now.room = "Lobby"
      # Lobby.listen(client.user.clientId, client.now.show_tables)

      callback(null, tables) if callback?
    )
  
  ## Gameplay related functions
  everyone.now.bet = (amount, callback, client = this) ->
    Bernie.place_bet(client.now.room, client.now.player, amount, callback)

  everyone.now.get_hands = (client = this) ->
    return Bernie.get_hands(client.now.room, client.now.player, client.now.receive_action)

  everyone.now.hit = () -> Bernie.request_action(client.now.room, client.now.player, "hit")
  
  everyone.now.stand = () -> Bernie.request_action(client.now.room, client.now.player, "stand")

  everyone.now.deal = () -> 
    # Single player only
    Bernie.request_action(client.now.room, client.now.player, "deal")
    
  ## Development related functions (for testing stuff)
  everyone.now.test_poke = (callback) ->
    # console.log(Bernie.games)
    callback(Bernie.games)

  everyone.now.inspect = (callback) ->
    callback({Lobby: Lobby, Dealer: Bernie})
  

  ## Nowjs Event Listeners
  nowjs.on("connect", () ->
    # TODO: give client a version #
    client = this
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
    Lobby.leave(client.now.room, client.now.player, (err, tables) ->)
    # Lobby.unlisten(client.user.clientId)
  )

  
  
  return everyone