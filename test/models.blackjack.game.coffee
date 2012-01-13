should = require("should")

Dealer = require("../app/models/blackjack/dealer")
reference_deck = require("./models.blackjack.cardfactory").reference_deck

describe("Dealer", () ->
  it("should initialize", (done) ->
    (() ->
      d = new Dealer()
    ).should.not.throw()
    done()
  )

  it("should initialize with custom rules", (done) ->
    rules = {
      decks: 8,
      seats: 4
    }
    (() ->
      d = new Dealer(rules)
      d.rules.seats.should.equal(4)
    ).should.not.throw()
    done()
  )

  it("should use default rules for unspecified custom rules", (done) ->
    rules = {
      decks: 8,
      seats: 4
    }
    (() ->
      d = new Dealer(rules)
      d.rules.bet.max.should.equal(100)
    ).should.not.throw()
    done()
  )

  it("should let you edit rule functions", (done) ->
    rules = {
      decks: 8,
      player_reward: {
        blackjack: (bet) ->
          return 2*bet
      }
    }
    d = new Dealer(rules)
    d.rules.player_reward.blackjack(100).should.equal(200)
    done()
  )

  it("should let you overwrite one nested function w/ others intact", (done) ->
    rules = {
      decks: 8,
      player_reward: {
        blackjack: (bet) ->
          return 2*bet
      }
    }
    d = new Dealer(rules)
    d.rules.player_reward.should.have.ownProperty("push")
    done()
  )
)