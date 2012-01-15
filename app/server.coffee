_ = require("underscore")
backbone = require("backbone")
# browserchannel = require("browserchannel").server
express = require('express')
hogan = require("hogan.js")
hogan_adapter = require("./lib/hogan-express")
n2o = require("nitrous")
nowjs = require("now")
redis = require("redis")
sharejs = require("share").server
url = require("url")

monkeypatch = require("./lib/monkeypatch_sharejs").patch()
blackjack = require("./lib/blackjack")
asset = { # TODO: pull from spoondate into nitrous
  manager: require('connect-assetmanager'), 
  handler: require('connect-assetmanager-handlers'),
  helpers: require("../scripts/assets")
}

class WebServer #extends backbone.Model
  start: () ->
    @stop() if app?.fd?

    @app = app = express.createServer()
    app.configure(() ->
      app.set("root", __dirname)
      app.set("views", __dirname + "/views")
      app.set("view engine", "html")
      app.register("html", hogan_adapter.init(hogan, app))
    )
    nitrous = new n2o(app, __dirname)
    @config = app.config # convenience interface

    # TODO: pull from spoondate into nitrous
    asset_config = app.config.assets
    assets_middleware = asset.manager(asset_config)
    asset.helpers.js()
    # asset.helpers.css()

    app.configure("development", "production", () ->
      app.use(nitrous.init())
      app.use(express.bodyParser())
      app.use(express.cookieParser())
      # app.use(express.logger()) # TODO: use winston
      app.use(express.favicon(__dirname + "/public/favicon.ico"))
      # app.use(express.static(__dirname + "/public", {maxAge: 86400000})) # TODO: switch on when finished
      app.use(express.static(__dirname + "/public"))
      app.use(express.session(app.config.session.store(app)))
      app.use(express.errorHandler({dumpExceptions:true,showStack:true})) # TODO: pull out of production

      app.use(nitrous.mvc())
      app.use(blackjack.helpers())
      app.use(assets_middleware)

      app.use(express.router(nitrous.routes()))
    )

    app.dynamicHelpers({
      'assetsCacheHashes': (req, res) ->
        assets_middleware.cacheHashes.js = 0 if !assets_middleware.cacheHashes.js?
        assets_middleware.cacheHashes.css = 0 if !assets_middleware.cacheHashes.css?
        return assets_middleware.cacheHashes
      'session': (req, res) -> return req.session
    })

    # share_options = {
    #   db: {
    #     type: "redis",
    #   },
    #   auth: (client, action) ->
    #     console.log(client)
    #     action.accept()
    # }
    # _.extend(share_options.db, app.config.redisConfig)
    # sharejs.attach(app, share_options)

    @everyone = nowjs.initialize(app)
    
    app.listen(app.config.port, () ->
      console.log("listening on port #{app.config.port}")
    )
    app.on("close", () ->
      console.log("server closed")
    )
  stop: () ->
    nowjs.server.close()
    @app.close()

  restart: () ->
    @stop()
    @start()

app = new WebServer()
app.start()

module.exports = app



# app.configure("development", () ->
#   app.use(express.errorHandler({dumpExceptions:true,showStack:true}))
# )
# app.configure("production", () ->
#   app.use(express.errorHandler())
# )


module.exports = app