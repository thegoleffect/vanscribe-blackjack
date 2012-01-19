_ = require("underscore")
EE = require("../common/ee")
Random = require("../../lib/alea")()
util = require("util")
{adjectives, nouns, ints} = require("../../lib/username-words")

class Manager extends EE
  signal: "tables"
  constructor: (@max_tables = 5) ->
    @tables = {}
    @members = {}
    @names = {} # TODO: Could get quite large & does not persist through restarts: please fix

    @create("#{i}") for i in [0..@max_tables-1]
  
  # "Data" API
  _default: (options = {}) -> 
    # Note: if you add to this, keys must be shallow (1 deep)
    base = {
      players: [],
      max_players: 6,
      betrange: [10, 100],
      private: null
    }
    base.private = options.private if options.private?
    base.max_players = options.max_players if options.max_players?
    # base.betrange = options.betrange if options.betrange? # FUTURE: enable this when user-lvl room-creation enabled
    return base

  _randindex: (len) -> return Math.floor(Random() * (len - 1))
  
  _name: (name = null) ->
    tries = 0
    while (not name or name in @names)
      name = [
        adjectives[@_randindex(adjectives.length)],
        nouns[@_randindex(nouns.length)],
        ints[@_randindex(ints.length)]
      ].join("-")
      tries++
      throw "name generation returned invalid result (#{name})" if name == "" or name == "--"
      console.log("name generator has exceeded max tries (#{tries})") if tries >= 25
    return name

  _new_player: (name = @_name()) ->
    player_obj = {
      username: name,
      purse: 500
    }
    console.log("generated _new_player() =>")
    console.log(player_obj)
    console.log("=========")
    return player_obj

  # "Public" API
  join: () ->
    members_card = @_new_player()
    @members[members_card.username] = 1
    return members_card
  
  sign_in: (members_card) ->
    @members[members_card.username] = 1
    # return members_card

  create: (name, options = {}) ->
    @tables[name] = @_default()
    # @emit(@_signal("update"), null, {
    #   type: "create"
    # }, () -> ) # FUTURE: enable if users can create rooms

  employ: (dlr) ->
    # @dealer = dlr
    @_register(dlr.update)
  
  rasterize: (table_obj) ->
    t = []
    for own k,v of table_obj
      open = v.players.length < v.max_players
      taken = v.players.length
      seats = v.max_players

      outobj = {
        name: k, 
        open: open,
        seats: seats,
        taken: taken,
        private: v.private,
        betrange: v.betrange,
      }

      t.push(outobj)
    return t


  list: (callback = null) -> 
    output = @rasterize(@tables)
    callback(null, output) if callback
    return output
  
  listen: (clientId, callback) ->
    callback(null, @tables)
    @listeners[clientId] = callback
    @on(@_signal('update'), callback)
  
  unlisten: (clientId) ->
    @removeListener(@_signal('update'), @listeners[clientId])

  sit: (table_name, user, onUpdate, callback) ->
    util.debug("inside manager sit")
    return callback("Table '#{table_name}' was not found") if not @tables[table_name]?
    return callback("Table is full") if @_already_full(table_name)
    return callback("User must exist & have username") if not user or not user.username
    return callback("User must register by join()") if user.username not in _.keys(@members)
    # return callback("Table is private") # FUTURE: enable if users can create rooms
    util.debug("after manager.sit error checking")

    # return callback(null, table_copy) if @_already_seated_here(table_name, user)
    if not @_already_seated_here(table_name, user)
      util.debug("user not already seated here")
      @tables[table_name].players.push(user.username)
      @emit(@_signal("update"), null, {
        action: "sit",
        table_name: table_name
        user: user,
        onUpdate: onUpdate
      }, callback)
    util.debug("sit completed")
    # callback(null, table_copy)

  leave: (table_name, user, callback) ->
    return callback("Invalid table name supplied (#{table_name})") if not @tables[table_name]?
    return callback("User must exist & have username") if not user or not user.username
    return callback("User must register by join()") if user.username not in _.keys(@members)
    return callback("Cannot stand up unless already seated.") if not @_already_seated_here(table_name, user)
    # Note: if hand in progress and player has bet => bet is forfeit

    index = @tables[table_name].players.indexOf(user.username)
    delete @tables[table_name].players[index]
    @tables[table_name].players = @tables[table_name].players.filter((d) -> typeof d != "undefined")

    @emit(@_signal("update"), null, {
      action: "stand",
      table_name: table_name
      user: user
    }, callback)
    # @dealer.remove_player(table_name, user, (err, status) ->
    #   console.log("should have removed player from dealer")
    #   return callback(err) if err

    #   self.emit(self._signal("update"), self.tables)
    #   callback(null, self.tables)
    # )
  

  _already_seated_here: (table_name, user) ->
    # FUTURE: change to a more optimal data structure w/ distributed version
    return user.username in @tables[table_name].players 
  
  _already_full: (table_name) ->
    t = @tables[table_name]
    return t.players.length == (t.max_players - 1)

module.exports = Manager