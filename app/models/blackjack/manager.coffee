_ = require("underscore")
EE = require("../common/ee")
Random = require("../../lib/alea")()
{adjectives, nouns, ints} = require("../../lib/username-words")

class Manager extends EE
  signal: "tables"
  constructor: (@max_tables = 5) ->
    @tables = {}
    @members = {}
    @names = {} # TODO: Could get quite large
    # @dealer = null

    @create("Table #{i}") for i in [0..@max_tables-1]
  
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
    # base.betrange = options.betrange if options.betrange? # FUTURE: let players adj this?
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
      throw "name generation returned invalid result (#{name})" if name == "" or name == "--" or tries >= 25
    return name

  _new_player: (name = @_name()) ->
    return {
      username: name,
      purse: 500
    }

  # "Public" API
  join: () ->
    members_card = @_new_player()
    @members[members_card.username] = 1
    return members_card
  
  sign_in: (members_card) ->
    @members[members_card.username] = 1
    return members_card

  create: (name, options = {}) ->
    @tables[name] = @_default()
    @emit(@_signal("update"), null, {
      type: "create"
    }, () -> ) # FUTURE: move to a delta signal

  employ: (dlr) ->
    # @dealer = dlr
    @_register(dlr.update)

  list: (callback = null) -> callback(null, @tables) if callback
  
  listen: (clientId, callback) ->
    callback(null, @tables)
    @listeners[clientId] = callback
    @on(@_signal('update'), callback)
  
  unlisten: (clientId) ->
    @removeListener(@_signal('update'), @listeners[clientId])

  sit: (table_name, user, onUpdate, callback) ->
    # console.log("about to sit() error check")
    return callback("Table '#{table_name}' was not found") if not @tables[table_name]?
    return callback("You are already seated here") if @_already_seated_here(table_name, user)
    return callback("Table is full") if @_already_full(table_name)
    return callback("User must exist & have username") if not user or not user.username
    return callback("User must register by join()") if user.username not in _.keys(@members)
    # return callback("Table is private") # TODO: 
    # console.log("sit error checkers")

    @tables[table_name].players.push(user.username)
    s = @_signal('update')
    # console.log("about to emit(#{s}) ")
    @emit(@_signal("update"), null, {
      action: "sit",
      table_name: table_name
      user: user,
      onUpdate: onUpdate
    }, callback)
    # console.log("emit'd")

    # @dealer.add_player(table_name, user, onUpdate, (err, state) ->
    #   return callback(err) if err
    #   self.emit(self._signal("update"), self.tables)

    #   callback(null, state)
    # )

  leave: (table_name, user, callback) ->
    # console.log("inside Lobby.leave(#{table_name})")
    return callback("Invalid table name supplied (#{table_name})") if not @tables[table_name]?
    return callback("User must exist & have username") if not user or not user.username
    return callback("User must register by join()") if user.username not in _.keys(@members)
    return callback("Cannot stand up unless already seated.") if not @_already_seated_here(table_name, user)
    # console.log("after leave's error checking")
    # Note: if hand in progress and player has bet => it is forfeit

    index = @tables[table_name].players.indexOf(user.username)
    # console.log("index of user = #{index}")
    delete @tables[table_name].players[index]
    # console.log("=========")
    # console.log("contents of @tables[#{table_name}].players: ")
    # console.log(@tables[table_name].players)
    # console.log("=========")
    @tables[table_name].players = @tables[table_name].players.filter((d) -> typeof d != "undefined")
    # console.log("removed player from manager? " + (user.username not in @tables[table_name].players))

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

  # "Private" API
  # _register: (callback) ->
  #   # Used by Dealer to update table data based on Manager's changes
  #   @on(@_signal("update"), callback)
  #   @on(@_signal("update"), () ->
  #     console.log("tables::update detected:")
  #     console.log(arguments)
  #   )

  _already_seated_here: (table_name, user) ->
    # FUTURE: change to a more optimal data structure w/ distributed version
    return true if user.username in @tables[table_name].players 
    return false
  
  _already_full: (table_name) ->
    t = @tables[table_name]
    return true if t.players.length == (t.max_players - 1)
    return false

module.exports = Manager