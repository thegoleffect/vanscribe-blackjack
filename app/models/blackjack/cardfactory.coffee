class CardFactory
  FrenchRanks: [].concat(['Ace'],[2..10],["Jack", "Queen", "King"])
  FrenchSuits: ["Spades", "Clubs", "Diamonds", "Hearts"]

  constructor: (ranks = @FrenchRanks, suits = @FrenchSuits) ->
    @ranks = ranks
    @suits = suits

    class Card
      constructor: (@r = 0, @s = 0) ->
        @validate()
      
      validate: () ->
        throw "inputs must be numbers" if typeof @r != 'number' or typeof @s != "number"
        throw "rank in Card(rank, suit) outside of selectable range" if not (0 <= @r < ranks.length)
        throw "suit in Card(rank, suit) outside of selectable range" if not (0 <= @s < suits.length)
      
      rank: () ->
        return ranks[@r]
      
      suit: () ->
        return suits[@s]
    
    @Card = Card
    return this
  
  deck: (d = []) ->
    for suit, s in @suits
      for rank, r in @ranks
        d.push(new @Card(r, s))
    return d
  
  identify: (c) ->
    return [@ranks[c.r], @suits[c.s]]

module.exports = CardFactory