# class BlackjackGame
#   constructor: () ->
#     console.log("new Blackjack obj created")


# window.BlackjackGame = BlackjackGame

create_menu = () ->
  m = new Menu(document.querySelector('#bet'), {
    radius: 100,
    degrees: 90,
    offset: -90
  })
  actions = new Menu(document.querySelector("#actions"), {
    radius: 100,
    degrees: 90,
    offset: 180
  })

$(document).ready(() ->
  create_menu()

  now.ready(() ->
    console.log('now is ready')
    # TODO: get server's cliside code version & alert user if out of date

    # Nowjs Server functions
    ## General functions
    now.receiveChat = (name, message, timestamp) ->
      console.log(timestamp, name, message)
    
    ## Table Lobby related functions
    # now.show_tables = (err, tables) ->
    #   console.log("[err]: " + err) if err
    #   console.log(tables)
    
    ## Game related functions
    now.load_game = (err, data) ->
      throw err if err or not data
      console.log("table data: ")
      console.log(err, data)
      # TODO: draw view
      if data.hand_in_progress
        # TODO: present wait alert msg
      else
        # TODO: ask user to pick bet amount to get started

    now.receive_action = (err, data) ->
      console.log("received action")
      console.log(err, data)
      now.get_hands() if data.action == "dealt"

    # now.listen_tables()
  )
  
  return null
)

