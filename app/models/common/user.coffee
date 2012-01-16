_ = require("underscore")
async = require("async")
bcrypt = require("bcrypt")
# UsernameModel = require("./username")
hat = require("hat")


# Calavera = require("./calavera/index")
{adjectives, nouns} = require("../../lib/username-words")

class UserModel
  n: [0..99]
  key: ":users"
  TTL: 604800 # save for a week
  constructor: (@client, @prefix = "") ->
    @rack = new hat.rack()
    
  default_data: (name, sid) ->
    return {
      username: name,
      secret: @rack(),
      sid: sid,
      purse: 500,
      created_at: +new Date()
    }

  query: (type, input) ->
    switch type
      when "sid"
        output = @prefix + [":sid", input].join(":")
      when "secret"
        output = @prefix + [":secret", input].join(":")
      when "user"
        output = @prefix + [@key, input].join(":")
      else 
        throw "invalid query type requested"
    console.log("query -> #{output}")
    return output

  load: (req, callback) -> 
    # takes an express request & returns user data
    self = this
    sid = req.cookies["connect.sid"]
    secret = req.session.secret || null
    username = req.session.username || null
    
    flow = []
    flow.push( (cb) -> self.anon(sid, (err, username, secret) -> cb(err, username, secret)) ) if not username or not secret
    flow.push( (cb) -> cb(null, username, secret)) if username and secret
    flow.push( (username, secret, cb) -> self.get(username, secret, (err, user) -> cb(err, user)) )
    async.waterfall(flow, (err, user) ->
      return callback(err) if err or not user
      callback(err, user)
    )

  login: (username, sid, password, callback) ->
    # @client.get(@query("name"))
  
  register: (username, secret, data, callback) ->
    @client.get(@query("secret", secret), (err, stored_name) =>
      return callback(err || "Username unavailable.") if err or stored_name != username

      data.password = bcrypt.encrypt_sync(data.password, bcrypt.gen_salt_sync(10)) if data.password?
      @set(username, data, callback)
    )

  get: (username, secret, callback) ->
    # console.log("get received username: #{username}, sid = #{sid}")
    @client.hgetall(@query("user", username), (err, obj) ->
      if err or secret != obj.secret
        callback(err || "invalid credentials")
      else
        callback(err, obj)
    )

  set: (username, data, callback) ->
    @client.HMSET(@query("user", username), data, callback)

  anon: (sid, callback) ->
    console.log("adj", adjectives.length)
    name = [adjectives[Math.floor(Math.random()*(adjectives.length - 1))], nouns[Math.floor(Math.random()*(nouns.length - 1))], @n[Math.floor(Math.random()*(@n.length - 1))]].join("-")
    console.log("new anon name = #{name}")
    @client.multi()
      .setnx(@query("sid", sid), name)
      .expire(@query("sid", sid), @TTL)
      .exec((err, replies) =>
        return callback(err) if err

        console.log("anon replies =") 
        console.log(replies)
        if replies[0] == 0 # already have a username
          @client.get(@query("sid", sid), (err, d) ->
            callback(err, d)
          )
        else
          data = @default_data(name, sid)
          @set(name, data, (err, res) ->
            callback(err, name, data.secret)
          )
      )


module.exports.UserModel = UserModel


#   auth: (username, sid, callback) ->
#     self = this

#     fns = []
#     fns.push( (cb) -> self.Username.create(sid, (err, username) -> cb(err, username)) ) if username == null
#     fns.push( (cb) -> self.ownership(username, sid, (err, username) -> cb(err, username)) ) if username != null

#     async.waterfall(fns, (err) -> callback(err))

#   key: (username, type) ->
#     return @Username.key(username) if type == "sid"
#     return @_prefix + [@prefix, ":#{username}", ":#{type}"].join("")
  
#   login: (username, input, callback) ->
#     @client.get(@key(username, "password"), (err, hash) ->
#       return callback(err) if err

#       bcrypt.compare(input, hash, (err, res) ->
#         return callback(err || "invalid credentials") if err or res == false

#         return callback(err, username)
#       )
#     )

#   save: (username, sid, password, data, callback) ->
#     self = this
#     @check_username_ownership(username, sid, (err, owned_by_you) ->
#       return callback(err || "#{username} not owned by you") if err or not owned_by_you

#       bcrypt.gen_salt(10, (err, salt) ->
#         bcrypt.encrypt(password, salt, (err, hash) ->
#           return callback(err) if err

#           self.client.set(self.key(username, "password"), hash, (err, res) ->
#             if err or  res != "OK"
#               callback(err || "unable to save user", false)
#             else
#               callback(err, true)
#           )
#         )
#       )
#     )
  


#   ownership: (username, sid, callback) ->
#     @client.get(@Username.key(username), (err, rsid) ->
#       return callback(err, null) if err or sid != rsid
#       callback(null, username)
#     )

# module.exports = User