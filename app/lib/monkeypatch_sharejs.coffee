fs = require("fs")
path = require("path")

module.exports.patch = (db_file = "./sharejs/redis.coffee") ->
  fullpath = path.join(__dirname, db_file)
  if !path.existsSync(fullpath)
    throw "no such file found (#{fullpath})"
  else
    output_path = path.join(__dirname, "../../node_modules/share/src/server/db/redis.coffee")
    # Backup output_path file
    if path.existsSync(output_path)
      backup_content = fs.readFileSync(fullpath).toString()
      fs.writeFileSync(output_path + ".bak", backup_content)

    contents = fs.readFileSync(fullpath).toString()
    fs.writeFileSync(output_path, contents)
  