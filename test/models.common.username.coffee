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
rclient = redisClient(RC)
prefix = ":debug"
sid = "LdqPgucOh4SghklDjSriVLgr.aoAYxRDM0FtuXsqCUfv4y7pKBjedBa8+1XAOq6g9DQM"


describe("Username", () ->
  Username = new UsernameModel(rclient, prefix)

  beforeEach((done) ->
    done()
  )
  afterEach((done) ->
    done()
  )

  it("should have access to redis in unittests", (done) ->
    (() ->
      rclient.keys(":debug:hippo", (err, keys) ->
        should.not.exist(err)
      )
    ).should.not.throw()
    done()
  )

  it("should instantiate", (done) ->
    should.exist(Username)
    done()
  )

  it("should generate a valid username", (done) ->
    name = Username.random()
    should.exist(name)
    name.should.be.a("string")
    name.should.not.equal("")
    name.split("-").length.should.equal(3)
    done()
  )

  it("should generate unique usernames and delete them", (done) ->
    Username.create(sid, (err, username) ->
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