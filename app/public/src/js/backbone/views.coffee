App = window.App

class BaseView extends Backbone.View
  constructor: () ->
  
  template: (context) ->
    return App.Templates[@tmpl].text(context, App.Partials)

class Lobby extends BaseView
  el: $("#alltables")
  tmpl: "partials/blackjack/listtables"
  events: {
    "click a.open": "sit_down",
  }

  # constructor: () ->
  #   @el = el if el
  #   @render(context)
  #   console.log(@el)
  #   return this

  render: (context) ->
    this.el.html(@template(context))
    this.delegateEvents()
    return this
  
  sit_down: (event) ->
    console.log(event.target.id)
    console.log(App.R)
    App.R.navigate("table/" + event.target.id, true)

App.Views.Base = BaseView
App.Views.Lobby = Lobby