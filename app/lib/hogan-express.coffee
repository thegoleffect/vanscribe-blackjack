# adapted from: http://allampersandall.blogspot.com/2011/12/hoganjs-expressjs-nodejs.html

fs = require("fs")
path = require("path")
Traversal = require("./traversal")

load_partials = (hogan, app) ->
  partials = {}
  partials_dir = path.join(app.settings.views, "/partials")
  opts = {
    functions: { 
      pre: () -> 
        return
      post: (startPath, currentFile, selected) ->
        # console.log(currentFile)
        selected_path = currentFile.replace(startPath + "/", "")
        selected.push(selected_path)
    }
  }
  # console.log("partials_dir = #{partials_dir}")
  T = new Traversal(partials_dir, "html", opts)
  partials_list = T.traverse()

  for partial in partials_list
    # console.log(partial)
    name = partial.replace(/\//g, "-").split(".")
    ext = name.pop()
    target = partials_dir + "/" + partial
    
    try
      contents = fs.readFileSync(target).toString()
    catch error
      console.log("could not find #{target} in views/partial/index.coffee:31") # TODO: better logging
      throw error
    partials[name[0]] = hogan.compile(contents)
  return partials

HoganExpressAdapter = () ->
  init = (hogan, app) ->
    partials = load_partials(hogan, app)
    compile = (source) ->
      return (options) ->
        return hogan.compile(source).render(options, partials)
    return {compile: compile}
  return {init: init}

module.exports = HoganExpressAdapter()