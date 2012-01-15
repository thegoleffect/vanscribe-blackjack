module.exports.get = (req, res) ->
  res.render("index/index", {
    dealer: {
      username: "Dealer"
    }
    current_player: {
      username: "vanscribe",
      purse: 500,
    }
    players: [
      {username: "BustyBunny86", purse: 500}
      {username: "CunningChris76", purse: 500}
    ]
  })

module.exports.heartbeat = (req, res) -> 
  res.send("1")
