express = require('express')


helpers = () ->
  return (req, res, next) ->
    res.psend = (data, pure = false) ->
      output = JSON.stringify(data, null, 2)
      output = "<pre>" + output + "</pre>" if !pure
      res.send(output)
    
    next()

app = express.createServer()
app.config = {} # TODO: use nitrous later

app.configure(() ->
  app.use(helpers())
)
app.configure("development", "production", () ->
  app.use(express.logger())
)

app.get("/", (req, res) ->
  res.send("Ohai.")
)

app.get("/config", (req, res) ->
  secret = req.param("secret", "")
  if secret != "hippo"
    res.send("Not found", 404)
  else
    res.psend(process.env)
)

app.get("/xyzzyx", (req, res) -> res.send("1")) # LB/Proxy Heartbeat

app.config.port = process.env.PORT || 3000
app.listen(app.config.port, () ->
  console.log("listening on port #{app.config.port}")
)
app.on("close", () ->
  console.log("server closed")
)

module.exports = app