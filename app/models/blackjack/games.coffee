_ = require("underscore")
async = require("async")
hat = require("hat")
sharejs = require("share").client

# Backbone = require("./backbone")
Dealer = require("./dealer")
Player = require("./player")
# Game = require("./game")

class GamesModel
  key: ":table"
  constructor: (@client, @prefix = "") ->
    @rack = hat.rack()
  
  default_data: (gid, user) ->
    console.log("default_data: (gid, user)")
    console.log(gid, user)
    d = new Dealer()
    d.add_player(user)
    d.table.id = gid
    return d.table

  list: () ->
    # TODO: 
    # return _.keys(@active_games)

  query: (type, input) ->
    switch type
      when "open", "closed"
        output = @prefix + ":#{type}"
      when "table"
        output = @prefix + [@key, input].join(":")
      else 
        throw "invalid input to GamesModel.query: #{type}"
    console.log("game.query(#{type}) = #{output}")
    return output

  load: (req, user, callback) ->
    self = this
    gid = req.session.table || null
    console.log("games sees user: ")
    console.log(user)

    flow = []
    flow.push( (cb) -> self.open_seat(user, (err, gid) -> cb(err, gid)) ) if not gid
    flow.push( (cb) -> cb(null, gid) ) if gid
    flow.push( (gid, cb) -> self.sit(gid, user, (err, user, state) -> cb(err, user, state)) )
    async.waterfall(flow, (err, user, state) ->
      return callback(err) if err or not state
      console.log( "games.waterfall: arguments")
      console.log(arguments)

      callback(err, user, state)
    )
  
  open_seat: (user, callback) ->
    console.log("about to zrangebyscore")
    @client.zrangebyscore(@query("open"), 1, "+inf", "WITHSCORES", (err, res) =>
      console.log("after zrangebyscore")
      return callback(err) if err

      if res.length == 0
        console.log("about to new")
        @new(user, callback)
      else
        callback(err, res[0])
    )
  
  new: (user, callback) ->
    gid = @rack()
    console.log("newing")
    @client.hlen(@query("table", gid), (err, reply) =>
      console.log("hlen:")
      console.log(reply)
      return callback(err) if err

      if reply == 1
        @new(user, callback)
      else
        @set(gid, @default_data(gid, user), (err, res) ->
          callback(err, gid)
        )
    )

  set: (gid, data, callback) ->
    console.log("set(gid, data, cb) -> ")
    console.log(gid, data)
    @client.set(@query("table", gid), JSON.stringify(data), (err, ok) ->
      callback(err, gid)
    )

  sit: (gid, user, callback) ->
    @client.get(@query("table", gid), (err, state) ->
      if err
        callback(err || "invalid credentials")
      else
        console.log("sit #{gid}, #{user.username}")
        state = JSON.parse(state)
        callback(err, user, state)
    )


module.exports.GamesModel = GamesModel