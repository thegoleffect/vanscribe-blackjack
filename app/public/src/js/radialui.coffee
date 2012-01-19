App = window.App

class RadialUI
  constructor: () ->
    throw "Menu object is required to use RadialUI" if not Menu?
    @init()

  init: () ->
    # App.Routers.Menu = new Menu(document.querySelector('#bet'), {
    #   radius: 100,
    #   degrees: 90,
    #   offset: -90
    # })
    # $('#bet').hide()
    App.Routers.Actions = new Menu(document.querySelector("#actions"), {
      radius: 100,
      degrees: 90,
      offset: 180
      # radius: 100,
      # degrees: 60,
      # offset: 190
    })

window.RadialUI = RadialUI