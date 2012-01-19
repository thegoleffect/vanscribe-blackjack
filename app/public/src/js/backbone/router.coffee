App = window.App

class LobbyRouter extends Backbone.Router
  routes: {
    "": "index",
    "table/:name": "sit_down",
    "test": "test"
  },
  index: () ->
    # now.stand_up()
    now.get_tables_list((err, tables) ->
      ctx = {}
      ctx.tables = tables
      LobbyView = new App.Views.Lobby()
      LobbyView.render(ctx)
    )
  
  sit_down: (name) ->
    console.log("router.sit_down(#{name})")
    now.sit_down(name)
  
  test: () ->
    console.log("test page")

App.Routers.Lobby = LobbyRouter