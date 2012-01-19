window.is_monitoring_history = false

App = window.App = {
  Routers: {},
  Partials: {},
  Templates: {},
  Views: {},
  KV: {},
  init: () ->
    
    status = Backbone.history.start()
    if not status
      console.log("current route was not found")
    else
      console.log("backbone loaded successfully")
}

$(document).ready(() ->
  now.ready(() ->
    App.Router = new App.Routers.Lobby()
    App.API = new App.Routers.Now()
    App.RadialUI = new RadialUI() # TODO: move into a router?

    for own name, tmpl of App.Templates
      if name.slice(0, 9) == "partials/"
        p_name = name.slice(9).split("/").join("-")
        App.Partials[p_name] = tmpl
        App.Partials[p_name].r = App.Partials[p_name].text

    # if not is_monitoring_history
    #   is_monitoring_history = true
    #   App.init(now)
    # else
    #   console.log("not monitoring history right now")
  )
  return null # Prevents accidental automatic return insertion
)