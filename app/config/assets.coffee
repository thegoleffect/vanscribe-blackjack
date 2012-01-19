handlers = require("../lib/assets")
path = require("path")
root = path.join(__dirname, "../../")

assetSettings = {
  html: {
    "path": path.join(root, "./app/views"),
    "aggregate_file": "../public/.templates.js",
    "dataType": "html",
    "files": [

    ]
  },
  js: {
    "route": /\/static\/js\/[a-z0-9]+\/.*\.js/,
    "path": path.join(root, "./app/public/src/js/"),
    "aggregate_file": "../../.app.coffee",
    "dataType": "javascript",
    "files": [
      # "https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js",
      # "http://localhost:#{process.env.PORT}/nowjs/now.js",
      "../../js/libs/json2.js",
      "../../js/libs/underscore-1.3.0.min.js",
      "../../js/libs/backbone-0.5.3.min.js",
      "../../js/libs/hogan.js-1.0.3.js",
      "../../js/libs/radial-menu.js",
      "../../js/plugins.js",
      # "../../.app.coffee",
      "../../src/js/index.coffee",
      "../../src/js/radialui.coffee",
      "../../src/js/nowhandlers.coffee",
      "../../src/js/backbone/router.coffee",
      "../../src/js/backbone/views.coffee",
      "../../.templates.js",
    ],
    "preManipulate": {
      "^": [ handlers.coffeeRenderer ]
    },
    "postManipulate": {
      "^": [ handlers.finalize("js") ]
    }
  },
  css: {
    "route": /\/static\/css\/[a-z0-9]+\/.*\.css/,
    "path": path.join(root, "./app/public/src/css/"),
    "aggregate_file": "../../.app.less",
    "dataType": "css",
    "files": [
      # "http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css",
      # "../../bootstrap/bootstrap.min.css",
      # "../../bootstrap/lib/*.less",
      # "../../bootstrap/lib/bootstrap.less",
      "index.less",
      "../css/playingcards/*"
      # "../../css/prettify.css"
    ],
    "preManipulate": {
      "^": [
        handlers.lessRenderer 
      ]
    },
    "postManipulate": {
      "^": [
        # handlers.fixVendorPrefixes,
        # handlers.fixGradients,
        # handlers.replaceImageRefToBase64(__dirname+'/public'),
        # handlers.yuiCssOptimize,
        handlers.finalize("less")
      ]
    }
  }
}
if process.env.NODE_ENV == "production"
  nowjs_url = "http://blackjack.vanscribe.com/nowjs/now.js"
else
  nowjs_url = "http://localhost:#{process.env.PORT}/nowjs/now.js"  
assetSettings.js.files.unshift(nowjs_url)
# console.log("unshifted #{nowjs_url}")


module.exports = assetSettings