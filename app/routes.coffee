module.exports = (nitrous) ->
  return (app) ->
    Controllers = nitrous.Controllers
    app.get("/xyzzyx", Controllers.index.index.heartbeat) # LB/Proxy Heartbeat

    app.get("/", Controllers.index.index.get)
    app.get("/blackjack", Controllers.blackjack.index.get)