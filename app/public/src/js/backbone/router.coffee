App = window.App

class LobbyRouter extends Backbone.Router
  routes: {
    "": "index",
    "lobby": "list_tables",
    "table/:name": "sit_down",
    "test": "test"
  },

  index: () ->
    now.get_room((err, room) ->
      console.log("index called() with room = #{room}")
      if room == "Lobby"
        App.Router.navigate("lobby", true)
      else
        App.Router.navigate("table/" + encodeURIComponent(room), true)
    )
  
  list_tables: () ->
    now.get_tables_list((err, tables) ->
      return App.Router.navigate("lobby", true) if err == "Table is full"
      
      ctx = {}
      ctx.tables = tables

      console.log(ctx)
      App.Views.Lobby.render(ctx)
      App.KV.tables = tables
    )
  
  _table_prefix: "Table "
  table_name: (name) -> return decodeURIComponent(name)

  sit_down: (name) ->
    # username = now.player.username
    console.log("Router.sit_down(): does now.sit_down exist? #{now?.sit_down?}")
    table_name = @table_name(name)
    if table_name != "Lobby"
      now.stand_up((err, response) ->
        throw (err) if err != "Cannot stand up unless already seated."  
        App.Views.Table.render(table_name)
      )
    else
      App.Views.Table.render(table_name)
    
  
  test: () ->
    console.log("test page")

App.Routers.Lobby = LobbyRouter