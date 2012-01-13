

module.exports.get = (req, res) ->
  return res.send("pass in a unique ?name=x") if !req.session.name? && !req.param("name", null)

  game_id = req.param("game_id", null) || req.session.game_id || null
  req.session.name ?= req.param("name")

  Games = new req.Models.games()
  MyGame = Games.load(req.session.name, game_id)

  res.send(MyGame)