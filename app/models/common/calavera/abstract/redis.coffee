class RedisModel
  constructor: (@client) ->
    
  create: (model, options, callback) ->
    @client.setnx(model.query(), model.toJSON(), (err, res) ->
      return callback(err || "cannot create, #{model.query()} already exists") if err or res == 0
      callback(null, model)
    )

module.exports = RedisModel