EventEmitter = require("events").EventEmitter
class EE extends EventEmitter
  _signal: (name) ->
    throw "Must set @signal prefix on descendant class" if not @signal?
    return [@signal, name].join("::")

module.exports = EE