_ = require("underscore")
async = require("async")
# EventEmitter = require("events").EventEmitter
util = require('util')

Dealer = require("../../models/blackjack/dealer")
EE = require("../../models/common/ee")
Manager = require("../../models/blackjack/manager")

stripNowjs = (obj, where = null) ->
  if typeof obj != 'object'
    util.debug(where) if where
    throw "Can't stripNowjs on a #{typeof obj}"
  else
    clone = {}
    for own key, value of obj
      clone[key] = value
  return clone


module.exports = (nowjs, nitrous, app) ->
  subscribe = app.redis.subscribe
  publish = app.redis.publish
  everyone = nowjs.initialize(app, {socketio: nitrous.settings.socketio})

  Lobby = new Manager()
  Bernie = new Dealer(Lobby.tables)

  Lobby.on(Lobby._signal("update"), (err, data, callback) ->
    Bernie.update(err, data, callback)
  )
  
  ## Nowjs User Functions
  ## TODO: namespace the functions somehow
  everyone.now.get_room = (callback) ->
    client = this
    util.debug("client requested room name: #{client.now.room}")
    callback(null, client.now.room)
  
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
  
  everyone.now.sit_down = (name, listener, callback) ->
    client = this
    util.debug("about to Lobby.sit(#{name})")
    # on_update ?= client.now.receive_action
    Lobby.sit(name, stripNowjs(client.now.player, "player in sit_down"), listener, (err, table) ->
      return callback(err) if err
      client.now.room = name
      callback(err, table)
    )
  
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
    util.debug("trying to bet in room: #{client.now.room}")
    Bernie.place_bet(client.now.room, stripNowjs(client.now.player, "player in bet"), amount, callback)
  
  everyone.now.get_table = (callback = () -> ) ->
    client = this
    return Bernie.sanitize(client.now.room, callback)
  
  everyone.now.get_purse = (callback = null) ->
    client = this
    return Bernie.get_purse(client.now.room, stripNowjs(client.now.player, "player in get_purse"), callback)

  everyone.now.hit = (callback = () ->) ->
    client = this
    return Bernie.request_action(client.now.room, stripNowjs(client.now.player, "player in hit"), "hit")
  
  everyone.now.stand = (callback = () ->) -> 
    client = this
    Bernie.request_action(client.now.room, stripNowjs(client.now.player, "player in stand"), "stand")
  
  everyone.now.deal = (callback = () ->) ->
    # Usage: now.deal()
    client = this
    Bernie.request_action(client.now.room, stripNowjs(client.now.player, "player in deal"), "deal", callback)
    
  ## Development related functions (for testing stuff) TODO: delete these
  everyone.now.test_poke = (callback) ->
    # Usage: now.test_poke(function(){ console.log(arguments); }) or games = now.test_poke()
    callback(Bernie.games)

  everyone.now.inspect = (callback) ->
    callback({Lobby: Lobby, Dealer: Bernie})
  
  everyone.now.self = (callback) ->
    client = this
    callback(null, stripNowjs(client.now.player, "player in self"))
  

  ## Nowjs Event Listeners
  nowjs.on("connect", () -> # TODO: give client a cliside js version # or md5
    client = this

    sid = decodeURIComponent(client.user.cookie["connect.sid"])
    app.session_store.get(sid, (err, session) ->
      throw err if err

      util.debug("user #{client.user.clientId} connected (sid = '#{sid}''):" + JSON.stringify(session))
      if session.blackjack?
        # TODO: auth user
        if not client.now.player
          # console.log("setting client.now.player")

          # client.now.set({
          #   username: session.blackjack.username,
          #   purse: session.blackjack.purse
          # }, () ->
          #   util.debug("now.player is set")
          # )
          client.now.room ?= session.blackjack.room || "Lobby"
          nowjs.getGroup(client.now.room).addUser(client.user.clientId)
          # client.now.player = session.blackjack
          client.now.player = {}
          client.now.player["username"] = session.blackjack.username if session.blackjack.username?
          client.now.player["purse"] = session.blackjack.purse || 500
        else
          # TODO: verify match
          verified = true
          for own key, val in session.blackjack
            if client.now.player[key] != val
              verified = false
          util.debug("FYI: #{verified}: client reconnected w/ existing data that matches session data")
        
        Lobby.sign_in(client.now.player)
        util.debug("after signin:")
        util.debug(JSON.stringify(client.now.player))
      else
        session.blackjack = client.now.player = Lobby.join()
        client.now.room = "Lobby"
        nowjs.getGroup(client.now.room).addUser(client.user.clientId)
        util.debug("Lobby.join(): ")
        util.debug(JSON.stringify(session.blackjack))
        app.session_store.set(sid, session, () ->)
      
      # util.debug("trying to call client.now.connected?")
      # util.debug(client.now.connected?)
      # client.now.connected()
    )
  )

  nowjs.on("disconnect", () ->
    # TODO: clean up all connections & listeners
    client = this
    console.log("#{client.user.clientId} disconnected")
    
    console.log("purse amt @ disconnection = " + client.player.purse) if client.player?.purse?

    # TODO: persist tables, data, etc
    sid = decodeURIComponent(client.user.cookie["connect.sid"])
    app.session_store.get(sid, (err, session) ->
      app.session_store.set(sid, session, () ->)
    )

    nowjs.getGroup(client.now.room).removeUser(client.user.clientId)

    
    Lobby.leave(client.now.room, client.now.player, (err, tables) ->)
  )
  
  # cleanup = (callback) ->
  #   nowjs.getGroups((groups) ->
  #     for g in groups
  #       nowjs.getGroup(g)
  #   )
  
  # process.once("SIGUSR2", () ->
  #   cleanup(() ->
  #     process.kill(process.pid, 'SIGUSR2')  
  #   )
  # )
  
  
  return everyone