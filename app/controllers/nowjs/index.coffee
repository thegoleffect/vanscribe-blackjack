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
      console.log("[stripNow]: ", key, value)
      clone[key] = value
  return clone


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
    util.debug("client requested room name: #{client.now.room}")
    callback(client.now.room) if callback?
  
  everyone.now.sendChat = (message) ->
    client = this
    nowjs.getGroup(client.now.room).now.receiveChat(client.now.player.username, message, +new Date())
  
  # everyone.now.tables_listSync = () -> 

  everyone.now.tables_list = (callback = null) ->
    # Usage: now.tables_list(function(){ util.debug(arguments); })
    util.debug("before client init")
    util.debug(JSON.stringify(this.now.player))
    client = this
    util.debug("after client init")
    util.debug(JSON.stringify(client.now.player))
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
    player = stripNowjs(client.now.player)
    util.debug("about to Lobby.sit()")
    util.debug("player:")
    util.debug(JSON.stringify(player))
    Lobby.sit(name, player, client.now.receive_action, client.now.load_game)
    # Bernie.ack(name, client.now.player, client.now.receive_action)
  
  everyone.now.stand_up = (callback = null) ->
    client = this
    # TODO: Dealer.cash out?

    Lobby.leave(client.now.room, client.now.player, (err, tables) ->
      throw err if err

      # TODO: factor out into separate fn
      nowjs.getGroup(client.now.room).removeUser(client.user.clientId)
      client.now.room = "Lobby"
      nowjs.getGroup(client.now.room).addUser(client.user.clientId)
      # Lobby.listen(client.user.clientId, client.now.show_tables)

      callback(null, tables) if callback?
    )
  
  ## Gameplay related functions
  everyone.now.bet = (amount, callback) ->
    client = this
    Bernie.place_bet(client.now.room, client.now.player, amount, callback)

  everyone.now.get_hands = () ->
    client = this
    return Bernie.get_hands(client.now.room, client.now.player, client.now.receive_action)

  everyone.now.hit = (callback = () ->) ->
    client = this
    return Bernie.request_action(client.now.room, client.now.player, "hit")
  
  everyone.now.stand = (callback = () ->) -> 
    client = this
    Bernie.request_action(client.now.room, client.now.player, "stand")

  everyone.now.deal = (callback = () ->) ->
    # Usage: now.deal()
    client = this
    Bernie.request_action(client.now.room, client.now.player, "deal", callback)
    
  ## Development related functions (for testing stuff)
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

    util.debug("just connected: client.now.player: ")
    util.debug(JSON.stringify(client.now.player))

    sid = decodeURIComponent(client.user.cookie["connect.sid"])
    app.session_store.get(sid, (err, session) ->
      throw err if err

      util.debug("session for sid (#{sid}):")
      util.debug(session)

      if session.blackjack?
        # TODO: auth user
        util.debug("before setting from session.blackjack")
        util.debug(JSON.stringify(client.now.player))
        util.debug("======================")
        util.debug("session.blackjack to json")
        util.debug(JSON.stringify(session.blackjack))
        
        # client.now.player = session.blackjack
        if not client.now.player?
          client.now.player = {}
          client.now.player["username"] = session.blackjack.username if session.blackjack.username?
          client.now.player["purse"] = session.blackjack.purse if session.blackjack.purse?
        else
          # TODO: verify match

        util.debug("before Lobby.sign_in(): ")
        util.debug(JSON.stringify(client.now.player))
        Lobby.sign_in(client.now.player)
        util.debug("after signin:")
        util.debug(JSON.stringify(client.now.player))
      else
        session.blackjack = client.now.player = Lobby.join()
        util.debug("Lobby.join(): ")
        util.debug(JSON.stringify(session.blackjack))
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