async = require("async")

module.exports.get = (req, res) ->
  Username = new req.Models.common.username(req.redis.client)


  # if not req.session.username?
  #   setup = [
  #     ((callback) ->
  #       Username.new((err, username) ->

  #     ))
  #   ]
  # else
  #   setup = [
  #     ((callback) ->

  #     )
  #   ]
  
  res.render("index/index", {
    current_player: {
      username: "vanscribe",
      purse: 500,
    }
    players: [
      {username: "BustyBunny86", purse: 500},
      {username: "CunningChris76", purse: 500},
      {username: "DirtyDave27", purse: 500},
      {username: "EnviousElla2", purse: 500}
    ]
  })

    
  

module.exports.heartbeat = (req, res) -> 
  res.send("1")
