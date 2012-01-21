should = require("should")
Dealer = require("../app/models/blackjack/dealer")

describe("Dealer", () ->
  it("should initialize", (done) ->
    (() ->
      d = new Dealer()
    ).should.not.throw()
    done()
  )

  describe("#_hand_value", () ->
    d = new Dealer()
    it("should work without aces", (done) ->
      hand = [{r:10}, {r:12}]
      val = d._hand_value(hand)
      val.should.equal(20)
      done()
    )
    it("should work with one ace first, total < 21", (done) ->
      hand = [{r:0}, {r:2}]
      d = new Dealer()
      val = d._hand_value(hand)
      val.should.equal(14)
      done()
    )
    
    it("should work with one ace last, total < 21", (done) ->
      hand = [{r:2}, {r:0}]
      val = d._hand_value(hand)
      val.should.equal(14)
      done()
    )
    
    it("should work with one ace first, total > 21", (done) ->
      hand = [{r:0}, {r:8}, {r:9}]
      val = d._hand_value(hand)
      val.should.equal(20)
      done()
    )
    
    it("should work with A,6,7,10", (done) ->
      hand = [{r:0}, {r:5}, {r:6}, {r:9}]
      val = d._hand_value(hand)
      console.log(val)
      val.should.equal(24)
      done()  
    )
  )
  
  
)






# should = require("should")

# Dealer = require("../app/models/blackjack/dealer")
# reference_deck = require("./models.blackjack.cardfactory").reference_deck

# describe("Dealer", () ->
#   it("should initialize", (done) ->
#     (() ->
#       d = new Dealer()
#     ).should.not.throw()
#     done()
#   )


# )