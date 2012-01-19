App = window.App

class LobbyRouter extends Backbone.Router
  routes: {
    "": "index",
    "lobby": "list_tables",
    "table/:name": "sit_down",
    "test": "test"
  },

  index: () ->
    return now.stand_up(@index) if now.room != "Lobby"
      
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
      console.log(err)
      
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
    return now.stand_up(@index) if now.room != "Lobby"
    
    console.log("Router.sit_down(): does now.sit_down exist? #{now?.sit_down?}")
    table_name = @table_name(name)
    App.Views.Table.render(table_name)
    App.Views.Lobby.rm() if App.Views.Lobby.el.is(":visible")
  
  test: () ->
    console.log("test page")

App.Routers.Lobby = LobbyRouter