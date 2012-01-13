handlers = require("../lib/assets")
path = require("path")
root = path.join(__dirname, "../../")

module.exports = {
  js: {
    "route": /\/static\/js\/[a-z0-9]+\/.*\.js/,
    "path": path.join(root, "./app/public/src/js/"),
    "aggregate_file": "../../.app.coffee"
    "dataType": "javascript",
    "files": [
      "https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js",
      # "http://localhost:#{process.port}/nowjs/now.js",
      # "../../js/bootstrap-dropdown.js"
      # "../../js/injected.js",
      # "js/bootstrap-dropdown.js",
      # "js/bootstrap-alerts.js",
      "../../.app.coffee"
      # "../../js/prettify.js"
      # "../../js/css_browser_selector.js"
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
      "index.less"
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