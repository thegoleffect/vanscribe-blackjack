# wordlist modified from http://stackoverflow.com/questions/7666516/fancy-name-generator-in-node-js
adj_list = ["misty", "empty", "dry", "dark", "icy", "quiet", "white", "cool", "dawn", "wispy", "blue", "cold", "damp", "green", "long", "late", "bold", "muddy", "old", "red", "rough", "still", "small", "shy", "wild", "black", "young", "holy", "aged", "snowy", "proud"]
nouns_list = ["river", "moon", "rain", "wind", "sea", "snow", "lake", "pine", "leaf", "dawn", "hill", "cloud", "sun", "glade", "bird", "brook", "bush", "dew", "dust", "field", "fire", "grass", "haze", "night", "pond", "sound", "sky", "shape", "surf", "water", "wave", "water", "sun", "wood", "dream", "tree", "fog", "frost", "voice", "paper", "frog", "smoke", "star"]

class Username
  TTL: 17280 # seconds, adds leeway after session expires for sys time delays
  prefix: ":usernames"
  constructor: (@client, @_prefix = "", @adjectives = adj_list, @nouns = nouns_list) ->

  key: (username) ->
    return @_prefix + [@prefix, username].join(":")
  
  set: (username, sid, callback) ->
    @reserve(username, sid, (err, res) =>
      if err
        @create(callback)
      else
        callback(err, username)
    )
  
  create: (sid, callback) ->
    self = this
    username = @random() 
    @reserve(username, sid, (err, res) ->
      if err
        self.create(callback)
      else
        callback(err, username)
    )

  exists: (username, callback) ->
    @client.exists(@key(username), (err, res) ->
      callback(err, res == 1)
    )
  
  random_arr: (arr) ->
    throw "type mismatch in UsernameGenerator.random_arr(arr)" if typeof arr != typeof [1,2]
    output = arr[Math.floor(Math.random() * (arr.length - 1))]
    return output

  random: () ->
    return [@random_arr(@adjectives), @random_arr(@nouns), @random_arr([0..99])].join("-")
  
  reserve: (username, sid, callback) ->
    self = this
    @client.setnx(@key(username), sid, (err, res) =>
      return callback(err) if err

      if res == 0 # already exists
        callback("username already exists", false)
      else
        @client.expire(@key(username), @TTL, (err, res) ->
          return callback(err || "error setting TTL on #{username}") if err or res ==0

          callback(err, true)
        )
    )
  
  remove: (username, callback) ->
    @client.del(@key(username), (err, res) ->
      throw err if err

      callback(err, res == 1)
    )


module.exports = Username