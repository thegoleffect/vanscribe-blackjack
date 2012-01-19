assetHandler = require("connect-assetmanager-handlers")
coffee = require("coffee-script")
fs = require("fs")
less = require("less")
spawn = require("child_process").spawn
path = require("path")
util = require("util")
# parser = new(less.Parser)({
#   paths: [
#     # path.join(__dirname, ".."),
#     # path.join(__dirname, "../public/src/css/"),
#     path.join(__dirname, "../public/bootstrap/lib/")
#   ]
# })

notify = (msg) ->
  args = [
    "-s", "blackjack.vanscribe.com",
    "-m", msg
  ]
  spawn("growlnotify", args)


# coffeeRenderer & sassRenderer from http://www.oesmith.co.uk/post/4981762820/using-connect-assetmanager-with-sass-and-coffee-script
module.exports = {
  coffeeRenderer: (file, path, index, isLast, callback) ->
    if /\.coffee/.test(path)
      try
        output = coffee.compile(file)  
      catch error
        util.debug("unable to compile #{path}")
        throw error
      
      callback(output)
    else
      callback(file)
  
  lessRenderer: (file, lpath, index, isLast, callback) ->
    # notify("[assetmanager]: update css assets triggered") if index == 0

    if /\.less/.test(lpath)
      try
        parser = new(less.Parser)({
          paths: [
            path.join(__dirname, "../public/src/css/")
            # path.join(__dirname, "../public/bootstrap/lib/")
          ]
        })
      catch error
        console.log("[err]: unable to create less parser")
        throw error
      
      try
        parser.parse(file, (err, tree) ->
          if err
            console.log("err: #{err}")
            # callback("")
          else
            result = tree.toCSS({compress: true})
            callback(result)
        )
      catch error
        console.log("unable to parse #{file}")
        console.warn(error)
        throw error
      
    else
      callback(file)
  
  optimize: assetHandler.uglifyJsOptimize
  
  fixVendorPrefixes: assetHandler.fixVendorPrefixes
  
  fixGradients: assetHandler.fixGradients
  
  replaceImageRefToBase64: (p) ->
    return (file, path, index, isLast, callback) ->
      assetHandler.replaceImageRefToBase64(p)(file, path, index, isLast, callback)
  
  yuiCssOptimize: assetHandler.yuiCssOptimize
  
  finalize: (type) ->
    return (file, path, index, isLast, callback) ->
      msg = "[assetmanager]: #{type} assets updated"
      # console.log("connect-assetmanager has updated #{type} assets")
      console.log(msg)
      
      notify(msg)
      callback(file)
}