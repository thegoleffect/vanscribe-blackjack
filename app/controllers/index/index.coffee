module.exports.get = (req, res) ->
  res.render("index/index", {})

module.exports.heartbeat = (req, res) -> 
  res.send("1")
