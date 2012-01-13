Dealer = require("./dealer")
Player = require("./player")

class Games
  active_games: []

  constructor: () ->

  join: (game_id, player_id) ->
    if @active_games[gid]?
      # player = new Player(player_id)
      # @active_games[gid].add_player(player)
      @active_games[gid].players.push(player_id)
      return @active_games[gid]
    else
      @active_games[gid] = {players: [player_id]}
      return @active_games[gid]



module.exports = Games