_ = require("underscore")
express = require("express")
path = require("path")
redis = require("redis")
url = require("url")
util = require("util")

config = require("./config")

init_settings = (app) ->
  settings = config

  app.redis ?= {}
  for own name, hosturl of settings.databases.redis
    app.redis[name] = initialize_redis_client(hosturl)

  init_redis_session(app, settings, settings.sessions.redis)
  console.log('initialized settings')
  return settings

parse_redis_url = _.memoize((hosturl) ->
  redisConfig = url.parse(hosturl)
  [redisConfig.db, redisConfig.pass] = redisConfig.auth.split(":")
  return redisConfig
)

initialize_redis_client = (config, callback = null) ->
  config = parse_redis_url(config) if typeof config == "string"

  client = redis.createClient(config.port, config.hostname)
  client.auth(config.pass, (err) ->
    throw err if err
    callback(err, client) if callback?
  )
  return client

init_redis_session = (app, settings, hosturl = null) ->
  settings.session ?= {}
  
  if hosturl?
    config = parse_redis_url(hosturl)
    settings.session.store = {
      secret: settings.sessions.secret,
      maxAge: settings.sessions.maxAge,
      store: new app.redisStore({
        host: config.hostname,
        port: config.port,
        pass: config.pass
      })
    }
  else
    util.debug("falling back to session MemoryStore()")
    settings.session.store = {
      secret: settings.sessions.secret,
      maxAge: settings.sessions.maxAge,
      store: new express.session.MemoryStore()
    }
  
  app.session = settings.session.store
  app.session_store = settings.session.store.store


module.exports = init_settings