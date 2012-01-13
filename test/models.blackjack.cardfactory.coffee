should = require("should")

CardFactory = require("../app/models/blackjack/cardfactory")
module.exports.reference_deck = reference_deck = [{"r":0,"s":0},{"r":1,"s":0},{"r":2,"s":0},{"r":3,"s":0},{"r":4,"s":0},{"r":5,"s":0},{"r":6,"s":0},{"r":7,"s":0},{"r":8,"s":0},{"r":9,"s":0},{"r":10,"s":0},{"r":11,"s":0},{"r":12,"s":0},{"r":0,"s":1},{"r":1,"s":1},{"r":2,"s":1},{"r":3,"s":1},{"r":4,"s":1},{"r":5,"s":1},{"r":6,"s":1},{"r":7,"s":1},{"r":8,"s":1},{"r":9,"s":1},{"r":10,"s":1},{"r":11,"s":1},{"r":12,"s":1},{"r":0,"s":2},{"r":1,"s":2},{"r":2,"s":2},{"r":3,"s":2},{"r":4,"s":2},{"r":5,"s":2},{"r":6,"s":2},{"r":7,"s":2},{"r":8,"s":2},{"r":9,"s":2},{"r":10,"s":2},{"r":11,"s":2},{"r":12,"s":2},{"r":0,"s":3},{"r":1,"s":3},{"r":2,"s":3},{"r":3,"s":3},{"r":4,"s":3},{"r":5,"s":3},{"r":6,"s":3},{"r":7,"s":3},{"r":8,"s":3},{"r":9,"s":3},{"r":10,"s":3},{"r":11,"s":3},{"r":12,"s":3}]

describe("CardFactory", () ->
  describe("with default inputs", () ->
    CF = new CardFactory()

    it("should instantiate", (done) ->
      should.exist(CF)
      CF.should.have.property('deck')
      CF.should.have.property("Card")
      done()
    )

    it("should generate Cards", (done) ->
      c = new CF.Card(0, 3)
      d = new CF.Card(12, 2)
      should.exist(c)
      should.exist(d)
      done()
    )

    it("should not generate invalid Cards", (done) ->
      (() ->
        c = new CF.Card(-13, 3)  
      ).should.throw()
      (() ->
        d = new CF.Card(14, 1)
      ).should.throw()
      (() ->
        d = new CF.Card(0, 5)
      ).should.throw()
      done()
    )

    it("should generate correct cards for default French set", (done) ->
      c = new CF.Card(0, 3)
      c.rank().should.equal("Ace")
      c.suit().should.equal("Hearts")
      done()
    )
  )

  describe("with custom inputs", () ->
    CF = new CardFactory([].concat(['Ace'],[2..10],["Jack", "Knight", "Queen", "King"])) # Standard 56 card deck

    it("should instantiate", (done) ->
      should.exist(CF)
      CF.should.have.property('deck')
      CF.should.have.property("Card")
      done()
    )

    it("should generate Cards", (done) ->
      c = new CF.Card(13, 3)
      d = new CF.Card(10, 2)
      should.exist(c)
      should.exist(d)
      done()
    )

    it("should not generate invalid Cards", (done) ->
      (() ->
        c = new CF.Card(-13, 3)  
      ).should.throw()
      (() ->
        d = new CF.Card(15, 1)
      ).should.throw()
      (() ->
        d = new CF.Card(0, 5)
      ).should.throw()
      done()
    )

    it("should generate correct cards for this set", (done) ->
      c = new CF.Card(0, 3)
      c.rank().should.equal("Ace")
      c.suit().should.equal("Hearts")

      c = new CF.Card(11, 0)
      c.rank().should.equal("Knight")
      c.suit().should.equal("Spades")
      done()
    )
  )

  describe("#deck", () ->
    CF = new CardFactory()

    it("should generate standard reference deck", (done) ->
      d = CF.deck()
      for card, i in d
        d[i].r.should.equal(card.r)
        d[i].s.should.equal(card.s)
      done()
    )
  )
)