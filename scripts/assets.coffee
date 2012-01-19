# assets library 

_ = require("underscore")
fs = require("fs")
# hogan = require("hogan.js")
hogan = require("../node_modules/hogan.js/web/builds/1.0.3/hogan.js")
path = require("path")
util = require("util")
{exec, spawn} = require("child_process")

settings = {'assets': require("../app/config/assets")}
Traversal = require("../app/lib/traversal")
root_path = path.join(__dirname, "../")

module.exports.clean = (options = {}) ->
  js_path = path.join(root_path, settings.assets.js.path, settings.assets.js.aggregate_file)
  css_path = path.join(root_path, settings.assets.css.path, settings.assets.css.aggregate_file)
  
  to_delete = [
    js_path,
    css_path
  ]
  for item in to_delete
    [cmd, args] = ["rm", ["-vrf", item]]
    rm = spawn(cmd, args)
    rm.stdout.on("data", (data) ->
      util.log(data)
    )
    rm.stderr.on("data", (data) ->
      util.debug(data)
    )

module.exports.css = (options = {}) ->
  params = {
    overwrite: false,
    watch: options.watch || false # unused
  }
  opts = _.extend({}, settings.assets.css, params)
  start_path = settings.assets.css.path
  # console.log("css start_path = #{start_path}")
  css_files = new Traversal(start_path, "css", opts)
  css_files.aggregate()
  # console.log("done with css")

module.exports.js = (options = {}) ->
  params = {
    overwrite: false,
    watch: options.watch || false # unused
  }
  opts = _.extend({}, settings.assets.js, params)
  start_path = settings.assets.js.path
  # console.log("js start_path = #{start_path}")
  js_files = new Traversal(start_path, "js", opts)
  js_files.aggregate()
  # console.log("done with js")

module.exports.html = (options = {}) ->
  params = {
    overwrite: false
  }
  opts = _.extend({}, settings.assets.html, params)
  start_path = settings.assets.html.path
  html_files = new Traversal(start_path, "html", opts)

  tmpl_array = []
  preprocess = (filename, contents) ->
    name = filename.slice(start_path.length + 1, -5)
    compiled = hogan.compile(contents, {asString: true})
    # console.log(name)
    # console.log(compiled) if name == "partials/blackjack/listtables"
    
    tmpl_array.push("'" + name + "': new HoganTemplate(" + compiled + ")")
    # if "/partials/" in filename
    #   tmpl_array.push("'" + name + "': new HoganTemplate().r = " + compiled)
    # else
    #   tmpl_array.push("'" + name + "': new HoganTemplate(" + compiled + ")")
  
  postprocess = (outfile) ->
    fs.writeFileSync(outfile, 'window.App.Templates = {' + tmpl_array.join(",\n") + '};\n', 'utf-8')
  
  agg_file = html_files.aggregate(preprocess)
  ofile = path.join(start_path, agg_file.pop())
  postprocess(ofile)
  console.log("updated hogan.js files @ #{ofile} ")
















