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

if process.env.REDISTOGO_URL?
  settings.redisConfig = url.parse(process.env.REDISTOGO_URL)
  settings.redisConfig.pass = settings.redisConfig.auth.split(":").pop()

if process.env.NODE_ENV == "production"
  # do stuff to settings
else
  # do stuff to settings

# assetSettings = require("./assetmanager")
# settings.assetsSettings = assetSettings

module.exports = settings