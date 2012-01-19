class BaseApp extends Backbone.Model
  constructor: () ->
    @templates = {}
    @partials = {}

    @organize_templates()
  
  organize_templates: () ->
    throw "No templates detected" if not window.App.Templates

    for own name, tmpl of window.App.Templates
      if name.slice(0, 9) == "partials/"
        @partials[name.slice(9)] = tmpl
      else
        @templates[name] = tmpl




window.BaseApp = BaseApp


class AppRouter extends Backbone.Router
  routes: {
    "": "index",
    "test": "test"
  },
  index: () ->
    now.get_tables_list((err, tables) ->
      console.log("from inside index()")
      console.log(err, tables)
    )
  
  test: () ->
    console.log("test page")

window.AppRouter = AppRouter

# window.App.Views = Views = {}

class BaseView extends Backbone.View
  constructor: (@partials = window.App.partials, @templates = window.App.templates) ->
  
  template: (context) ->
    return @templates[@tmpl].render(context, @partials)

class Lobby extends BaseView
  id: "#alltables"
  tmpl: "partials/blackjack/listtables.html"

  render: (context) ->
    $(this.id).html(this.template(context))
    return this

Views = window.Views = {}
Views.Base = BaseView

# class BlackjackGame
#   constructor: () ->
#     console.log("new Blackjack obj created")


# window.BlackjackGame = BlackjackGame

class RadialUI
  constructor: () ->
    throw "Menu object is required to use RadialUI" if not Menu?
    @init()

  init: () ->
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

window.RadialUI = RadialUI

is_monitoring_history = false

$(document).ready(() ->
  App = window.App = new window.BaseApp()
  App.Router = new window.BaseRouter()

  now.ready(() ->
    API = new NowHandlers(now)
    UI = new RadialUI()

    if not is_monitoring_history
      is_monitoring_history = true
      Backbone.history.start({pushState: true})
  )
  return null # Prevents accidental automatic return insertion
)

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

