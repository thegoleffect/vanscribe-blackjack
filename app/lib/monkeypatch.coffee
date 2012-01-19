crypto = require("crypto")
fs = require("fs")
path = require("path")

module.exports.patch = (src = "./monkeypatches/sharejs/redis.coffee", destination = "../../node_modules/share/src/server/db/redis.coffee") ->
  source_path = path.join(__dirname, src)
  if !path.existsSync(source_path)
    throw "no such file found (#{source_path})"
  else
    output_path = path.join(__dirname, destination)

    # Check if monkeypatching is needed
    # console.log("checking if need to patch #{output_path} with #{source_path}:")
    backup_content = fs.readFileSync(output_path, 'utf-8').toString()
    output_contents = fs.readFileSync(source_path, 'utf-8').toString()

    orig_hash = crypto.createHash('md5').update(backup_content).digest("hex")
    output_hash = crypto.createHash('md5').update(output_contents).digest("hex")

    # console.log("orig_hash: #{orig_hash}")
    # console.log("output_hash: #{output_hash}")

    if orig_hash != output_hash
      console.log("[monkeypatcher]: patching file #{destination}")
      # Backup output_path file
      if path.existsSync(output_path)
        fs.writeFileSync(output_path + ".bak", backup_content, 'utf-8')
      
      fs.writeFileSync(output_path, output_contents, 'utf-8')
    else
      # No monkeypatch needed
      console.log("[monkeypatcher]: no patching needed")