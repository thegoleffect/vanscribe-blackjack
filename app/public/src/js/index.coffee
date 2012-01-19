is_monitoring_history = false

App = window.App = {
  Routers: {},
  Partials: {},
  Templates: {},
  Views: {},
  init: (now) ->
    App.R = new App.Routers.Lobby()
    App.API = new App.Routers.Now(now)
    for own name, tmpl of App.Templates
      if name.slice(0, 9) == "partials/"
        p_name = name.slice(9).split("/").join("-")
        App.Partials[p_name] = tmpl
      # App.Templates[name] = tmpl
    Backbone.history.start()
}

$(document).ready(() ->

  now.ready(() ->
    
    UI = new RadialUI()

    if not is_monitoring_history
      is_monitoring_history = true
      App.init(now)
  )
  return null # Prevents accidental automatic return insertion
)