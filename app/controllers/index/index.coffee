module.exports.get = (req, res) ->
  res.send("Ohai")

module.exports.heartbeat = (req, res) -> res.send("1")