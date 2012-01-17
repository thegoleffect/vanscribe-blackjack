# This file serves as reference for how some objects are organized throughout the code base.

describe("inside everyone.now.* functions", () ->
  it("should have: `now = client = this`, where: ", () ->
    client = {
      user: {
        clientId: "",
        cookie: {"connect.sid": ""}
      },
      now: {} # has shared state vars & fns,
      player: {
        # blackjack user info, NOTE: must be regularly saved to session.blackjack!
        username: "",
        purse: 500
      } 
    }
  )
)

