

UsernameModel = require("./username")
bcrypt = require("bcrypt")

class User
  prefix: ":users"
  constructor: (@client, @_prefix = "") ->
    @Username = new UsernameModel(@client, @_prefix)

  key: (username, type) ->
    return @Username.key(username) if type == "sid"
    return @_prefix + [@prefix, ":#{username}", ":#{type}"].join("")
  
  auth: (username, input, callback) ->
    @client.get(@key(username, "password"), (err, hash) ->
      bcrypt.compare(input, hash, (err, res) ->
        return callback(err, res)
      )
    )

  save: (username, sid, password, data, callback) ->
    self = this
    @check_username_ownership(username, sid, (err, owned_by_you) ->
      return callback(err || "#{username} not owned by you") if err or not owned_by_you

      bcrypt.gen_salt(10, (err, salt) ->
        bcrypt.encrypt(password, salt, (err, hash) ->
          return callback(err) if err

          self.client.set(self.key(username, "password"), hash, () ->
            console.log("redis.set args:")
            console.log(arguments)
          )

          callback(err, true)
        )
      )
    )
  
  check_username_ownership: (username, sid, callback) ->
    @client.sismember(@key(username, "sid"), username, (err, res) =>
      return callback(err || "username does not exist") if res == 0
      
      @client.get(@key(username, "sid"), (err, res) ->
        return callback(err) if err or res == null

        callback(err, res == sid)
      )
    )

module.exports = User