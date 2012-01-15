_ = require("underscore")
hat = require("hat")
sharejs = require("share").client

# Backbone = require("./backbone")
Dealer = require("./dealer")
Player = require("./player")
# Game = require("./game")

class Games
  constructor: (@redis_client) ->
    @rack = hat.rack()
  
  list: () ->
    # TODO: 
    # return _.keys(@active_games)

  load: (player_id, gid = rack(), callback) ->
    # TODO: fetch gid
    # sharejs.open(gid, "json", (err, doc) ->
    #   return callback(err, doc) if err

    #   marvin = new Dealer()
    #   if doc.created # new game started
    #     #
    #   else
    #     marvin.load(doc.get())
      
    # )


    # if @active_games[gid]?
    #   # player = new Player(player_id)
    #   # @active_games[gid].add_player(player)
    #   @active_games[gid].players.push(player_id)
    # else
    #   @active_games[gid] = {players: [player_id]}

    # callback([gid, @active_games[gid]])



module.exports = Games