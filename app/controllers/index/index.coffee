_ = require("underscore")
async = require("async")


module.exports.get = (req, res) ->
  res.render("index/index", {
    player: {
      username: "vanscribe",
      purse: 500
    },
    # table: {
    #   players: [
    #     {username: "BustyBunny86", purse: 500},
    #     {username: "CunningChris76", purse: 500},
    #     {username: "DirtyDave27", purse: 500},
    #     {username: "EnviousElla2", purse: 500}
    #   ]
    # }
  })

# TODO: switch Models to be in a cached required vs polluting req obj
# module.exports.get = (req, res) ->
#   UserModel = req.UserModel
#   GamesModel = req.GamesModel
#   setup = [
#     (cb) -> req.UserModel.load(req, (err, user) -> cb(err, user))
#     (user, cb) -> req.GamesModel.load(req, user, (err, user, table) -> cb(err, user, table))
#   ]
#   render = (user, table, cb) ->
#     req.session.username = user.username
#     req.session.secret = user.secret
#     req.session.table = table.id

#     state = table
#     delete state.players[user.username]
#     delete state.players if _.keys(state.players).length == 0
    
#     context = {
#       player: user,
#       table: state
#     }
#     cb(null, context)
  
#   setup.push(render)

#   async.waterfall(setup, (err, context) -> 
#     tmpl = "index/index"
#     if err
#       tmpl = "index/error" 
#       context = {}

#     console.log(arguments)

#     res.render(tmpl, context)
#   ) # TODO: pretty error handling

module.exports.heartbeat = (req, res) -> 
  res.send("1")
