_ = require("underscore")
fs = require("fs")
path = require("path")

default_options = {
  overwrite: true,
  watch: false,
  valid: {
    js: ["js", "coffee"],
    css: ["css", "less"],
    html: ["html", "tmpl", "hbs", "jade"]
  },
  functions: { # TODO: convert these to use logging and logging modes
    pre: () -> 
      # console.log("@options.functions.pre()")
    post: (startPath, currentFile, selected) ->
      selected_path = currentFile.replace(startPath + "/", "")
      selected.push(selected_path)
      # console.log("Found valid file at #{selected_path}")
  }
}

watchFile = (currentFile) ->
  fs.unwatchFile(currentFile)
  fs.watchFile(currentFile, (curr, prev) ->
    if curr.mtime > prev.mtime
      # console.log("#{currentFile} has been modified, updating css...")
      loadLessCSS()
  )

# count = 0

class Traversal
  constructor: (@startPath, @type = "js", options = {}) ->
    return throw "Traversal must be run as a module function" if !@startPath? and !__dirname?
    @options = _.extend({}, default_options, options)
    # console.log("default: " + default_options.functions.post.toString()) if @type == "html"
    # console.log("argument: " + options.functions.post.toString()) if @type == "html"
    # console.log("@options: " + @options.functions.post.toString()) if @type == "html"
    # Manually account for pre/post
    # @options.functions.pre = options.functions.pre if options.functions?.pre?
    # @options.functions.post = options.functions.post if options.functions?.post?
    # console.log(@options.functions.pre.toString()) if @type == "html"
    # console.log(@options.functions.post.toString()) if @type == "html"

    # @count = count = count + 1
    # console.log("[#{@count}]: new Traversal(#{@startPath}, #{@type}, #{JSON.stringify(@options)})")
    # console.log("[#{@count}]: aggregate = #{@options.aggregate_file}")
    
  recursiveWalk: (current_path, selected) =>
    files = fs.readdirSync(current_path)
    for file in files
      currentFile = "#{current_path}/#{file}"
      # console.log(file)
      if file[0] == "."
        # console.log("ignoring #{file}")
        continue # ignore hidden files
      if !fs.statSync(currentFile).isFile()
        # console.log("#{file}/ is a folder")
        @recursiveWalk(currentFile, selected)
      else
        for extension in @options.valid[@type]
          # console.log("#{file} is being tested as valid")
          if new RegExp(".#{extension}").test(file)
            # console.log("#{file} is a(n) #{extension} file")
            # console.log(@options.functions.post.toString())
            @options.functions.post(@startPath, currentFile, selected)
            continue
    
  traverse: () ->
    # options = @options if !options
    selected = []
    @options.functions.pre()
    # console.log("[#{@count}]: about to walk on #{@startPath}")
    # console.log("[#{@count}]: " + @options.functions.post.toString())
    @recursiveWalk(@startPath, selected)
    # console.log("[#{@count}]: done w/ startpath = #{@startPath}")
    # console.log("selected = #{selected}")
    return _.uniq(selected)
    
  aggregate: () ->
    return throw "No aggregate file specified" if !@options.aggregate_file?
    watch = @options.watch || false
    aggregate_file = @options.aggregate_file
    fns = _.clone(@options.functions)

    @options.functions.pre = () =>
      destination = path.join(@startPath, aggregate_file)
      # console.log("[#{@count}]: pre destination = #{destination}")
      if path.existsSync(destination)
        # console.log("deleting file")
        fs.unlinkSync(destination)
      fs.writeFileSync(destination, "")
      
    @options.functions.post = (startPath, currentFile, selected) =>
      destination = path.join(@startPath, aggregate_file)
      contents = fs.readFileSync(currentFile).toString()
      # console.log("[#{@count}]: post destination = #{destination}")
      if !path.existsSync(destination)
        # console.log("writing new files")
        f = fs.writeFileSync(destination, contents)
      else
        current = fs.readFileSync(destination)
        f = fs.writeFileSync(destination, current.toString() + contents.toString() + "\n\n")
        
      selected.push(aggregate_file)
      if watch
        watchFile(currentFile)
      
    return @traverse(@options)

module.exports = Traversal