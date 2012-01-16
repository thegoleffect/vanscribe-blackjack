$(document).ready(() ->
  create_menu()

  now.ready(() ->
    console.log('now is ready')

    now.show_tables = (err, tables) ->
      console.log("[err]: " + err) if err
      console.log(tables)

    now.listen_tables()
  )
  
  return null
)