module.exports = (nowjs, nitrous, app) ->
  everyone = nowjs.initialize(app, {socketio: {transports:['websocket', 'xhr-polling','jsonp-polling']}})

  # nowjs.on("connect", () ->
  #   # console.log("this.user:")
  #   # console.log(this.user)
  #   user = this.user

  #   sid = decodeURIComponent(this.user.cookie["connect.sid"])
  #   app.session_store.get(sid, (err, session) ->
  #     if err
  #       console.log("err", err)
  #       throw err 

  #     console.log("session:")
  #     console.log(session)
  #   )
  # )

  return everyone