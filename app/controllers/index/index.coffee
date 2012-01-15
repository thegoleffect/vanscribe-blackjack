async = require("async")

module.exports.get = (req, res) ->
  UserModel = new req.UserModel()
  setup = [
    (cb) -> UserModel.load(req, (err, user) -> cb(err, user)),
    (user, cb) -> GamesModel.load(req, user, (err, state) -> cb(err, user, state))
  ]
  render = (user, state, cb) ->
    req.session.username = user.username
    req.session.table = state.id
    res.render("index/index", {
      player: user,
      table: state
    })
  setup.push(render)
  async.waterfall(setup, (err) -> throw err) # TODO: pretty error handling

module.exports.heartbeat = (req, res) -> 
  res.send("1")
