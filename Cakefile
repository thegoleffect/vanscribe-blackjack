# module.paths.unshift("./node_modules")

coffee = require("coffee-script")
assets = require("./scripts/assets")

# settings = require("./app/config/index")
# Traversal = require("./app/lib/traversal")

desc = "run server"
task("run", desc, (options) ->
  # TODO: 
)

desc = "clean up generated files"
task("clean", desc, assets.clean)

desc = "aggregate and compile less client-side stylesheets"
task("css", desc, assets.css)

desc = "aggregate and compile coffeescript client-side js files"
task("js", desc, assets.js)

desc = "build css & js"
task("bake", desc, (options) ->
  invoke("clean")
  invoke("css")
  invoke("js")
)
task("build", desc, (options) ->
  invoke("bake")
)