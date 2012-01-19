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