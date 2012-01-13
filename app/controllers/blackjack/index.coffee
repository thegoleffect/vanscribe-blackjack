module.exports.get = (req, res) ->
  return res.send("pass in a unique ?name=x") if !req.session.name? && !req.param("name", null)

  req.session.game_id = req.param("game_id", null) || req.session.game_id || null
  req.session.name ?= req.param("name")

  Games = new req.Models.blackjack.games()
  Games.load(req.session.name, req.session.game_id, (err, results) ->
    [req.session.game_id, MyGame] = results
    res.send(results) # use this data to generate actionable links
  )
