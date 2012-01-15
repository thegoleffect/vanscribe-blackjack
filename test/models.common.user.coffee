async = require("async")
should = require("should")
util = require("util")

UserModel = require("../app/models/common/user")
RedisHelpers = require("./helpers/redis")

UMT = {
  hosturl: require("../app/config/config").databases.redis.general,
  key: ":debug",
  sid: "LdqPgucOh4SghklDjSriVLgr.aoAYxRDM0FtuXsqCUfv4y7pKBjedBa8+1XAOq6g9DQM",
  password: "12345",
  data: {
    purse: 500000
  },
  init_redis: RedisHelpers.init_redis,
  redisClient: RedisHelpers.redisClient
}

# hosturl = require("../app/config/config").databases.redis.general
{init_redis, redisClient} = 
UMT.RC = UMT.init_redis(UMT.hosturl)
UMT.rclient = UMT.redisClient(UMT.RC)


User = new UserModel(UMT.rclient, UMT.key)

describe("User", () ->
  beforeEach((done) ->
    done()
  )
  afterEach((done) ->
    done()
  )

  it("should instantiate", (done) ->
    should.exist(User)
    should.exist(User.Username)
    done()
  )


  describe("#Username", () ->
    it("should work as if not inside User class", (done) ->
      User.Username.create(UMT.sid, (err, username) ->
        should.exist(username)

        User.Username.remove(username, (err, res) ->
          res.should.equal(true)

          User.Username.exists(username, (err, status) ->
            should.not.exist(err)
            status.should.equal(false)
            done()
          )
        )
      )
    )
  )

  # TODO: refactor using async
  describe("#save", (done) ->
    User.Username.create(UMT.sid, (err, username) ->
      should.not.exist(err)
      should.exist(username)

      User.save(username, UMT.sid, UMT.password, UMT.data, (err, status) ->
        should.not.exist(err)
        should.exist(status)
        status.should.equal(true)

        UMT.rclient.get(User.key(username, "sid"), (err, stored_sid) ->
          should.not.exist(err)
          (stored_sid == UMT.sid).should.equal(true)

          User.Username.remove(username, (err, res) ->
            should.not.exist(err)
            should.exist(res)
            res.should.equal(true)

            User.Username.exists(username, (err, status) ->
              should.not.exist(err)
              status.should.equal(false)
              done()
            )
          )
        )
      )
    )
  )
)