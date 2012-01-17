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

    now.show_tables = (err, tables) ->
      console.log("[err]: " + err) if err
      console.log(tables)

    now.load_game = (err, data) ->
      console.log("table data: ")
      console.log(err, data)

    now.receive_action = (err, data) ->
      console.log("received action")
      console.log(err, data)

    now.listen_tables()
  )
  
  return null
)

