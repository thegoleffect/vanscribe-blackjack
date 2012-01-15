Calavera = require("./calavera")
Calavera.Model = require("./model")
Calavera.User = require("./user")
Calavera.Abstract = {
  RedisModel: require("./abstract/redis"),
  NowjsModel: require("./abstract/nowjs")
}

module.exports = Calavera