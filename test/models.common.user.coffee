async = require("async")
bcrypt = require("bcrypt")
should = require("should")
util = require("util")

UserModel = require("../app/models/common/user")

hosturl = require("../app/config/config").databases.redis.general
key = ":debug"
sid = "LdqPgucOh4SghklDjSriVLgr.aoAYxRDM0FtuXsqCUfv4y7pKBjedBa8+1XAOq6g9DQM"
password = "12345"
hash = bcrypt.encrypt_sync(password, bcrypt.gen_salt_sync(10))
data = {
  purse: 500000
}

# hosturl = require("../app/config/config").databases.redis.general
{init_redis, redisClient} = require("./helpers/redis")
RC = init_redis(hosturl)
rclient = redisClient(RC)

User = new UserModel(rclient, key)

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
      User.Username.create(sid, (err, username) ->
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

  errwrap = (callback, data = null, test = null) ->
    return (err, res) ->
      should.not.exist(err)
      should.exist(res)
      test.apply(this, ) if test?

      return callback(err, res, data) if data?
      callback(err, res)

  describe("#auth", () ->
    it("should authenticate a fake user", (done) ->
      username = User.Username.random()
      rclient.set(User.key(username, "password"), hash, (err, ok) ->
        should.not.exist(err)
        ok.should.equal("OK")

        User.auth(username, password, (err, res) ->
          should.not.exist(err)
          res.should.equal(true)

          rclient.del(User.key(username, "password"), (err, res) ->
            res.should.equal(1)
            done()
          )
        )
      )
    )
  )

  # TODO: refactor using async
  describe("#save", () ->
    it("should save", (done) ->
      # async.waterfall([
      #   (cb) -> User.Username.create(sid, errwrap(cb))
      #   (username, cb) -> User.save(username, sid, password, data, errwrap(cb, {username: username})
      #   (status, d, cb) -> rclient.get(User.key(extras.username), errwrap(cb, d, ))
      # ])

      User.Username.create(sid, (err, username) ->
        should.not.exist(err)
        should.exist(username)

        User.save(username, sid, password, data, (err, status) ->
          should.not.exist(err)
          should.exist(status)
          status.should.equal(true)

          rclient.get(User.key(username, "sid"), (err, stored_sid) ->
            should.not.exist(err)
            (stored_sid == sid).should.equal(true)

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
)