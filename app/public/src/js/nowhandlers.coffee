App = window.App

class NowHandlers
  constructor: () ->
    throw "global now variable not found" if not now?
    throw "nowjs is not connected" if not now.core.clientId
    console.log("now connected established")
    
    # Nowjs Server functions
    ## General functions
    now.receiveChat = (name, message, timestamp) ->
      console.log(timestamp, name, message)
    
    ## Game related functions
    ##-# Callbacks
    now.load_game = (err, table) ->
      # now.sit(table_name) => calls now.load_game(err, table)
      throw err if err or not table
      console.log("table data: ")
      console.log(err, table)
      # TODO: draw view
      # if data.hand_in_progress
      #   # TODO: present wait alert msg
      # else
      #   # TODO: ask user to pick bet amount to get started

    now.receive_action = (err, data) ->
      console.log("received action")
      console.log(err, data)
      App.KV[data.action] = data
      # now.get_hands() if data.action == "dealt"
    
    # TODO: poll until now pockets synchronized
    poll = setInterval((() ->
      console.log(now.player)
      if now.player
        clearInterval(poll)
        if not window.is_monitoring_history
          window.is_monitoring_history = true
          console.log("App.init()")
          App.init()
          $('#jsnoscript').remove()
        else
          console.log("not monitoring history right now")
    ), 1000)
    

App.Routers.Now = NowHandlers