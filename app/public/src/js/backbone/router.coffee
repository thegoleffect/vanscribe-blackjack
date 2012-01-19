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
    now.sit_down(table_name, (err, table) ->
      console.log("inside sit_down's callback")
      throw err if err
      console.log("table data:")
      console.log(table)

      # Automatically set a bet?
      now.bet(100, () ->
        ctx = {}
        ctx.table = {}
        ctx.table.players = table.seats.filter((d) ->
          if d == 'shy-fog-62' #username
            ctx.table.player = table.players[d]
            return false
          else
            return true
        )
        emptycount = table.max_players - 1 - ctx.table.players.length
        if emptycount > 0
          [1..emptycount].map((d) -> {id: d})
        
        console.log("ctx")
        console.log(ctx)
        window.ctx = ctx
        window.tmpl = App.Templates[App.Views.Table.tmpl]

        App.Views.Table.render(ctx)
      )
      

      # console.log("table context:")
      # console.log(ctx)

      # App.Views.Table.render(ctx)
    )
  
  test: () ->
    console.log("test page")

App.Routers.Lobby = LobbyRouter