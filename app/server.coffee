express = require('express')
hogan = require("hogan.js")
n2o = require("nitrous")
redis = require("redis")
url = require("url")

adapter = require("./lib/hogan-express")

app = express.createServer()

app.configure(() ->
  app.set("root", __dirname)
  app.set("views", __dirname + "/views")
  app.set("view engine", "html")
  app.register("html", adapter.init(hogan, app))
)

nitrous = new n2o(app, __dirname)

app.configure("development", "production", () ->
  app.use(nitrous.init())
  app.use(express.bodyParser())
  app.use(express.cookieParser())
  app.use(express.logger())
  app.use(express.favicon(__dirname + "/public/favicon.ico"))
  # app.use(express.static(__dirname + "/public", {maxAge: 86400000}))
  app.use(express.session(app.config.session(app)))

  app.use(nitrous.mvc())
)
app.configure("development", () ->
  app.use(express.errorHandler({dumpExceptions:true,showStack:true}))
)
app.configure("production", () ->
  app.use(express.errorHandler())
)


app.get("/config", (req, res) ->
  secret = req.param("secret", "")
  if secret != "hippo"
    res.send("Not found", 404)
  else
    output = {
      env: process.env,
    }
    res.psend(output)
)

app.get("/session", (req, res) ->
  res.psend(req.session)
)



# app.config.port = process.env.PORT || 3000
app.listen(app.config.port, () ->
  console.log("listening on port #{app.config.port}")
)
app.on("close", () ->
  console.log("server closed")
)

module.exports = app