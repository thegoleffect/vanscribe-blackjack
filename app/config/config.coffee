path = require("path")

settings = {
  debug: true,
  logger: {
    format: ":response-time ms - :date - :req[x-real-ip] - :method :url :user-agent / :referrer"
  },
  sessions: {
    secret: "44efd9e97f648d45988924f507dce7df",
    maxAge: 604800000,
    redis: process.env.REDISTOGO_URL || "redis://redistogo:3fa0997b72b7d7cc91d390992ff4b4f2@stingfish.redistogo.com:9620/"
  },
  databases: {
    redis: {
      general: "redis://thegoleffect:a613d30b9911406f1ed05dd34a1ecf88@chubb.redistogo.com:9079/",
      publish: "redis://thegoleffect:a613d30b9911406f1ed05dd34a1ecf88@chubb.redistogo.com:9079/",
      subscribe: "redis://thegoleffect:a613d30b9911406f1ed05dd34a1ecf88@chubb.redistogo.com:9079/"
    }
  }
}
settings.port = process.env.PORT = settings.port || process.env.PORT || 3000 # normalize port

settings.assets = require("./assets") if path.existsSync(path.join(__dirname, "./assets.coffee")) # needs to be after port
module.exports = settings