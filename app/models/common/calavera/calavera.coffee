class Calavera
  constructor: () ->
  
  sync: (method, model, options, callback) ->
    callback("AbstractModel is not defined for this class") if not @AbstractModel?

    # builtins = ["create", "read", "update", "delete"]
    try
      @AbstractModel[method](model, options, callback)
    catch error
      callback(err)

module.exports = Calavera