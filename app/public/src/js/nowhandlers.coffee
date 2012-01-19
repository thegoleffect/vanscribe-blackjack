App = window.App

class NowHandlers
  constructor: (now) ->
    throw "global now variable not found" if not now?
    throw "nowjs is not connected" if not now.core.clientId 
    console.log("now is connected")
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
      # now.get_hands() if data.action == "dealt"

App.Routers.Now = NowHandlers