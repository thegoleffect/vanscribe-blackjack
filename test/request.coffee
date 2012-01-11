express = require("express")
request = require("request")
should = require("should")

describe("request", () ->
  it("should work with express", (done) ->
    port = 3001
    app = express.createServer(
      # express.logger(),
      express.errorHandler({dumpExceptions:true,showStack:true})
    )
    app.get("/", (req, res) -> res.send("ok"))
    app.listen(port, () ->
      request("http://localhost:#{port}/", (err, res, body) ->
        should.not.exist(err)
        res.statusCode.should.equal(200)
        app.close()
        done()
      )
    )
  )
)
