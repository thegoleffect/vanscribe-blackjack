App = window.App

class BaseView extends Backbone.View
  constructor: () ->
  
  template: (context) ->
    return App.Templates[@tmpl].text(context, App.Partials)
  
  enc: (input) -> 
    return encodeURIComponent(input)

class Lobby extends BaseView
  el: $("#alltables")
  tmpl: "partials/blackjack/listtables"
  events: {
    "click a.open": "sit_down",
  }

  render: (context) ->
    this.el.hide()
      .html(@template(context))
      .slideDown()
    this.delegateEvents()
    return this
  
  rm: () ->
    this.el.slideUp()
    return this
  
  sit_down: (event) ->
    this.rm()
    App.Router.navigate("table/" + @enc(event.target.id), true)

class Table extends BaseView
  el: $("#current_table")
  tmpl: "partials/blackjack/table"

  render: (context) ->
    console.log("rendering #{@tmpl} with window.testcontext")
    window.testcontext = context
    this.el.hide()
      .html(@template(context))
      .slideDown()
      this.delegateEvents()
    return this




App.Views.Base = BaseView
App.Views.Lobby = new Lobby()
App.Views.Table = new Table()





