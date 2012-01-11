request = require("request")
should = require("should")


app = require("../app/server")


describe("server", () ->
  describe("#listen", () ->

    it("should run without errors", (done) ->
      done()
    )

    # it("should GET / => 200", (done) ->
    #   url = "http://localhost:#{app.config.port}/"
    #   setTimeout((() ->
    #     request(url, (err, res, body) ->
    #       console.log("body = #{body}")
    #       done()
    #     )
    #     ), 1000)
    # )

    # it("should respond with '1'", (done) ->
    #   url = "http://localhost:#{app.config.port}/xyzzyx"
    #   console.log(url)
    #   request(url, (err, res, body) ->
    #     throw err if err
    #     should.not.exist(err)
    #     res.statusCode.should.equal(200)

    #     # app.close()
    #     done()
    #   )
    # )
  )
)