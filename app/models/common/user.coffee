_ = require("underscore")
async = require("async")
bcrypt = require("bcrypt")
# UsernameModel = require("./username")


# Calavera = require("./calavera/index")


class UserModel extends Calavera.User
  constructor: (@attributes = {}) ->
    super(@attributes)

  query: () ->
    ":users:#{username}"

  load: (req) -> 
    # takes an express request & returns user data
    username = req.session.username || null
    session_id = req.cookies["connect.sid"]

    @set("username", username)

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