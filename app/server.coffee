express = require('express')


helpers = () ->
  return (req, res, next) ->
    res.psend = (data, pure = false) ->
      output = JSON.stringify(data, null, 2)
      output = "<pre>" + output + "</pre>" if !pure
      res.send(output)
    
    next()

app = express.createServer()
app.configure(() ->
  app.use(express.logger())
  app.use(helpers())
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

port = process.env.PORT || 3000
app.listen(port, () ->
  console.log("listening on port #{port}")
)