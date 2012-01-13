Alea = require("../../lib/alea")
CardFactory = require("./cardfactory")

class Deck
  constructor: (@num_decks = 1, @CF = new CardFactory()) ->
    throw "num_decks must be a number" if (parseFloat(@num_decks) != parseInt(@num_decks) || isNaN(@num_decks))
    throw "num_decks must be positive, non-zero" if @num_decks <= 0

    # @deck = []
    # @used = []

    # Generate reference_deck & start_decks once
    @reference_deck = @CF.deck()
    @start_deck = []
    for i in [0..@num_decks - 1]
      @start_deck.push.apply(@start_deck, @reference_deck.slice(0))
    
    # Set usable deck
    @reset()

  cards_total: () -> return @start_deck.length
  cards_remaining: () ->return @deck.length
  
  reset: () ->
    @used = [] # could technically remove @used but for debugging, this may help
    @deck = @start_deck.slice(0)
  
  shuffle: (seed = ("Sa1T3d" + +new Date() + "bUtt3R")) ->
    rand = Alea(seed).fract53
    @reset() # TODO: need to test shuffle repeatedly vs shuffle original
    for i in [@deck.length - 1..0]
      randint = Math.floor(rand() * (i + 1))
      [@deck[i], @deck[randint]] = [@deck[randint], @deck[i]]
  
  pop: () ->
    throw "oops out of cards, please shuffle" if @deck.length <= 0

    card = @deck.pop()
    @used.push(card)
    return card
  


module.exports = Deck