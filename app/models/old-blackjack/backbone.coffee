# Backbone = require("backbone")
# sharejs = require("sharejs").client

# class ShareJSModel
#   constructor: (@options) ->


# AbstractModel = Backbone.AbstractModel = ShareJSModel

# Backbone.sync = (method, model, options) ->
#   builtins = ["create", "read", "update", "delete"]
#   try
#     AbstractModel[method](model, options, (err, response) ->
#       if method in builtins
#         if err
#           if options.error?
#             options.error(err)
#           else
#             throw err
#         else
#           # console.log("about to options.success(response)")
#           options.success(response)
#       else
#         # console.log("about to options.success(err, response)")
#         options.success(err, response)
#     )
#   catch error
#     console.log(error)
#     throw error

# module.exports = Backbone