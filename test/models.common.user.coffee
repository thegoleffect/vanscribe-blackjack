should = require("should")
util = require("util")

UserModel = require("../app/models/common/username")

hosturl = require("../app/config/config").databases.redis.general
{init_redis, redisClient} = require("./helpers/redis")
RC = init_redis(hosturl)
rclient = redisClient(RC)
key = ":debug:users"

describe("User", () ->
  User = null

  beforeEach((done) ->
    User = new UserModel(rclient, key)
    done()
  )
  afterEach((done) ->
    # delete User.Username
    delete User
    done()
  )

  it("should instantiate", (done) ->
    (() ->
      # should.exist(User.Username)
      should.exist(User)
      should.exist(User.client)
    ).should.not.throw()
    done()
  )


  describe("#Username", () ->
    # it("should ")
  )
)