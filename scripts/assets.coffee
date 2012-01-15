# assets library 

_ = require("underscore")
fs = require("fs")
path = require("path")
util = require("util")
{exec, spawn} = require("child_process")

settings = require("../app/config/config")
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
    watch: options.watch || false
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
    watch: options.watch || false
  }
  opts = _.extend({}, settings.assets.js, params)
  start_path = settings.assets.js.path
  # console.log("js start_path = #{start_path}")
  js_files = new Traversal(start_path, "js", opts)
  js_files.aggregate()
  # console.log("done with js")



