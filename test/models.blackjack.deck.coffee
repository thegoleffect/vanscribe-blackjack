_ = require("underscore")
should = require("should")

Deck = require("../app/models/blackjack/deck")
reference_deck = require("./models.blackjack.cardfactory").reference_deck

describe("Deck", () ->
  it("should exist", (done) ->
    done()
  )

  it("should match reference for default French set", (done) ->
    d = new Deck()
    for card, i in d.deck
      card.r.should.equal(reference_deck[i].r)
      card.s.should.equal(reference_deck[i].s)
    done()
  )

  describe("#shuffle", () ->
    it("should not match reference for set seed", (done) ->
      d = new Deck()
      d.shuffle("")
      _.isEqual(d.deck, d.reference_deck).should.equal(false)
      done()    
    )
  )

  describe("with multiple decks of cards", () ->
    it("should spawn the right number of cards", (done) ->
      d = new Deck(6)
      d.deck.length.should.equal(6*52)
      done()
    )

    it("should not work with negative # of decks", (done) ->
      (() ->
        d = new Deck(-6)
      ).should.throw()
      done()
    )
    it("should not work float # of decks", (done) ->
      (() ->
        d = new Deck(1.5)
      ).should.throw()
      done()
    )
    it("should not work NaN # of decks", (done) ->
      (() ->
        d = new Deck("x")
      ).should.throw()
      done()
    )
  )
)