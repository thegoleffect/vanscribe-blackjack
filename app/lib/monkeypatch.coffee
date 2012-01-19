crypto = require("crypto")
fs = require("fs")
path = require("path")

module.exports.patch = (src = "./monkeypatches/sharejs/redis.coffee", destination = "../../node_modules/share/src/server/db/redis.coffee") ->
  fullpath = path.join(__dirname, src)
  if !path.existsSync(fullpath)
    throw "no such file found (#{fullpath})"
  else
    output_path = path.join(__dirname, destination)

    # Check if monkeypatching is needed
    console.log("checking if need to patch #{destination} with #{src}:")
    backup_content = fs.readFileSync(fullpath).toString()
    output_contents = fs.readFileSync(fullpath).toString()
    orig_hash = crypto.createHash('md5').update(backup_content).digest("hex")
    output_hash = crypto.createHash('md5').update(output_contents).digest("hex")

    if orig_hash != output_hash
      console.log("[monkeypatcher]: patching file #{destination}")
      # Backup output_path file
      if path.existsSync(output_path)
        fs.writeFileSync(output_path + ".bak", backup_content)
      # monkeypatch
      fs.writeFileSync(output_path, output_contents)
    else
      # No monkeypatch needed
      console.log("[monkeypatcher]: no patching needed")