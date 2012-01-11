module.exports = (nitrous) ->
  return (app) ->
    Controllers = nitrous.Controllers

    app.get("/", Controllers.index.index.get)
    app.get("/xyzzyx", Controllers.index.index.heartbeat) # LB/Proxy Heartbeat