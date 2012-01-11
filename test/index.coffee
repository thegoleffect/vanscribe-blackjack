request = require("request")
should = require("should")

app = require("../app/server").close()

describe("server", () ->
  describe("#listen", () ->
    it("should run without errors", (done) ->
      app.listen(app.config.port)
      app.close()
      delete app
      done()
    )
  )

  describe("GET /xyzzyx", () ->
    it("should respond with '1'", (done) ->
      app.listen(app.config.port)

      url = "http://localhost:#{app.config.port}/xyzzyx"
      request(url, (err, res, body) ->
        should.not.exist(err)
        res.statusCode.should.equal(200)

        app.close()
        delete app
        done()
      )
    )
  )
)