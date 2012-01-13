assetHandler = require("connect-assetmanager-handlers")
coffee = require("coffee-script")
fs = require("fs")
less = require("less")
spawn = require("child_process").spawn
path = require("path")
# parser = new(less.Parser)({
#   paths: [
#     # path.join(__dirname, ".."),
#     # path.join(__dirname, "../public/src/css/"),
#     path.join(__dirname, "../public/bootstrap/lib/")
#   ]
# })

# coffeeRenderer & sassRenderer from http://www.oesmith.co.uk/post/4981762820/using-connect-assetmanager-with-sass-and-coffee-script
module.exports = {
  coffeeRenderer: (file, path, index, isLast, callback) ->
    if /\.coffee/.test(path)
      output = coffee.compile(file)
      callback(output)
    else
      callback(file)
  
  lessRenderer: (file, lpath, index, isLast, callback) ->
    if /\.less/.test(lpath)
      parser = new(less.Parser)({
        paths: [
          path.join(__dirname, "../public/src/css/")
          # path.join(__dirname, "../public/bootstrap/lib/")
        ]
      })
      
      parser.parse(file, (err, tree) ->
        if err
          console.log("err: #{err}")
          # callback("")
        else
          result = tree.toCSS({compress: true})
          callback(result)
      )
      # less.render(file, (err, css) ->
      #   if err
      #     console.log(err)
      #   else
      #     callback(css)
      # )
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
      
      args = [
        "-s", "blackjack.vanscribe.com",
        "-m", msg
      ]
      spawn("growlnotify", args)
      callback(file)
}