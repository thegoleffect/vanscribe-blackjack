module.exports = (nitrous) ->
  return (app) ->
    Controllers = nitrous.Controllers
    # console.log(Controllers.index.index.heartbeat.toString())

    app.get("/", Controllers.index.index.get)
    app.get("/xyzzyx", Controllers.index.index.heartbeat) # LB/Proxy Heartbeat