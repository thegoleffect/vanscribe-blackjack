_ = require("underscore")
$ = require("jquery")
hat = require("hat")

Deck = require("./deck")
EventEmitter = require("events").EventEmitter

class Dealer extends EventEmitter
  hand_in_progress: false
  default_rules: {
    decks: 6,
    seats: 5,
    currency: "Chip",
    bet: {
      max: 100,
    },
    hand: {
      is_bust: (count) ->
        return count > 21
    },
    dealer: {
      should_hit: (count) ->
        return count < 17
      should_shuffle: (D) ->
        return D.cards_remaining() <= Math.floor(.25 * D.cards_total())
    },
    player_reward: {
      blackjack: (bet) -> return Math.floor(1.5*bet)
      push: (bet) -> return bet
      win: (bet) -> return 2*bet
    }
    use_hole: false,
  }

  constructor: (@ruleset = {}) ->
    @rules = $.extend(true, {}, @default_rules, @ruleset) # deep extend
    @decks = new Deck(@rules.decks)
    @rack = hat.rack()
    @table = {
      seats: {},
      free_seats: [@rules.seats - 1..0],
      pot: 0,
      players: {},
      hands: {},
      dealer_hand: []
    }

  add_player: (player) ->
    throw "cannot add player during a hand" if @hand_in_progress # TODO: switch to queue?
    throw "cannot sit at a full table" if @table.free_seats.length <= 0

    # @table.seats[uuid] = @table.free_seats.pop()
    uuid = rank() # hat already dbl checks for collisions
    pass = rank() # password to use for accessing player's cards
    @table.players[uuid] = p = {
      id: uuid,
      pass: pass,
      player: player,
      # seat: @table.seats[uuid],
      seat: @table.free_seats.pop(),
      joined: +new Date(),
      bet: 0
    }
    @table.hands[uuid] = []

    @emit('joined', p.id, p.joined, p.seat, p.player.purse)
    return p
  
  remove_player: (player_uuid) ->
    p = @table.players[uuid]
    seat = p.seat
    @table.free_seats.push(seat)
    @mit("left", p.id, new Date, p.seat)
    delete @table.players[uuid]
    delete @table.cards[uuid]

  has_bet: (uuid) ->
    return false if not @table.players[uuid]?
    return false if @table.players[uuid].bet <= 0
  
  seats: () ->
    return _.sortBy(@table.players.map((d) -> return d.seat), (d) -> +d)

  deal: () ->
    for i in @seats()
      player_uuid = @table.players[i]
      if not @has_bet(player_uuid)
        continue
      else
        @table.hands[player_uuid].push(@deck.pop())
    @table.dealer_hand.push(@deck.pop())

  start_hand: () ->
    @hand_in_progress = true
    @shuffle() if @rules.dealer.should_shuffle(@decks)
    
    # deal out cards mimicking real dealer
    @deal()
    @deal()
  
  finish_hand: () ->
    for i in @seats()
      player_uuid = @table.players[i]
      @table.cards[player_uuid] = []
    @table.dealer_hand = []
  
  get_hand: (uuid, pass) ->
    return "invalid credentials" if not @table.players[uuid]? or pass != @table.players[uuid].pass
    return @table.cards[uuid]
      


module.exports = Dealer