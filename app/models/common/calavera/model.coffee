_ = require("underscore")
# Backbone = require("backbone")

Calavera = require("./calavera")
# RedisModel = require("./abstract/redis")
# NowjsModel = require("./abstract/nowjs")

class Model extends Calavera
  constructor: () ->
    @attributes = {}
    @_previousAttributes = _.clone(@attributes)
    @_changed = false
    @_new = true
  
  toJSON: () -> _.clone(this.attributes);

  single_set: (key, value) ->
    throw "value must be supplied when setting a key using string" if not value?
    @attributes[key] = value
    @_changed = true
    return @attributes

  multi_set: (obj) ->
    for own k,v of obj
      @attributes[k] = v
    @_changed = true
    return @attributes
  
  set: (key, value = null) ->
    switch typeof key
      when "object"
        @multi_set(key)
      when "string"
        @single_set(key, value)
      else
        throw "invalid type passed to .set()"

  get: (key) -> return @attributes[key] || null

  new: () -> return @_new == true

  save: (options = {}, callback = () -> ) ->
    self = this
    method = if @new() then "create" else "update"
    @sync(method, this, options, (err, model) ->
      self._new = false
    )

  fetch: (options, callback = () -> ) ->
    @sync("read", this, options, (err, model) ->
      self._new = false
    )

  destroy: (options, callback = () -> ) ->
    @sync("delete", this, options, (err, model) ->
      self._new = true
    )

# class Collection extends Calavera
#   constructor: (@AbstractModel) ->
#     super(@AbstractModel)




# class Users extends Collection


# module.exports.RedisModel = RedisModel
# module.exports.Calavera = Calavera
module.exports = Model
# module.exports.Collection = Collection
# module.exports.User = User
# module.exports.Users = Users