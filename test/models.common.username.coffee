_ = require("underscore")
redis = require("redis")
should = require("should")
url = require("url")
util = require("util")

hosturl = require("../app/config/config").databases.redis.general
{init_redis, redisClient} = require("./helpers/redis")
UsernameModel = require("../app/models/common/username")

# Global Configuration
RC = init_redis(hosturl)
client = redisClient(RC)
key = ":debug:sets:usernames"


describe("UsernameGenerator", () ->
  beforeEach((done) ->
    # switched to shared, persistent redis connection
    done()
  )
  afterEach((done) ->
    done()
  )

  it("should have access to redis in unittests", (done) ->
    (() ->
      client.keys(":debug:hippo", (err, keys) ->
        should.not.exist(err)
      )
    ).should.not.throw()
    done()
  )

  it("should instantiate", (done) ->
    Username = null
    (() ->
      Username = new UsernameModel(client, key)
      should.exist(Username)
    ).should.not.throw()
    done()
  )

  it("should generate a valid username", (done) ->
    Username = new UsernameModel(client, key)
    name = Username.random()
    should.exist(name)
    name.should.be.a("string")
    name.should.not.equal("")
    name.split("-").length.should.equal(3)
    done()
  )

  it("should generate unique usernames and delete them", (done) ->
    Username = new UsernameModel(client, key)
    Username.create((err, username) ->
      should.not.exist(err)
      should.exist(username)

      Username.remove(username, (err, res) ->
        should.not.exist(err)
        should.exist(res)
        res.should.equal(true)

        Username.exists(username, (err, status) ->
          should.not.exist(err)
          status.should.equal(false)
          done()
        )
      )
    )
  )
)