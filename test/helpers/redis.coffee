_ = require("underscore")
redis = require("redis")
url = require("url")

# Helper functions
module.exports.init_redis = _.memoize((hosturl) ->
  RC = url.parse(hosturl)
  [RC.db, RC.pass] = RC.auth.split(":")
  return RC
)

module.exports.redisClient = (RC) ->
  client = redis.createClient(RC.port, RC.hostname)
  client.auth(RC.pass)
  return client