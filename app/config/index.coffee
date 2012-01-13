express = require("express")
path = require("path")
url = require("url")

settings = {
  # assetsSettings: assetSettings,
  debug: true,
  # external: authentication,
  logger: {
    format: ":response-time ms - :date - :req[x-real-ip] - :method :url :user-agent / :referrer"
  },
  session: {
    secret: "44efd9e97f648d45988924f507dce7df"
  },
}

settings.port = process.env.PORT || 3000
process.env.PORT ?= settings.port

settings.assets = require("./assets") if path.existsSync(path.join(__dirname, "./assets.coffee"))

if process.env.REDISTOGO_URL?
  settings.redisConfig = redisConfig = url.parse(process.env.REDISTOGO_URL)
  [redisConfig.db, redisConfig.pass] = redisConfig.auth.split(":")
  settings.session.store = (app) ->
    return {
      secret: settings.session.secret,
      store: new app.redisStore({
        host: redisConfig.hostname,
        port: redisConfig.port,
        # db: redisConfig.db,
        pass: redisConfig.pass
      })
    }
else
  settings.session.store = (app) ->
    return {
      secret: settings.session.secret,
      store: new express.session.MemoryStore()
    }


if process.env.NODE_ENV == "production"
  # do stuff to settings
else
  # do stuff to settings

# assetSettings = require("./assetmanager")
# settings.assetsSettings = assetSettings

module.exports = settings