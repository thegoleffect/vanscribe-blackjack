EventEmitter = require("events").EventEmitter
util = require("util")

class EE extends EventEmitter
  _signal: (name) ->
    throw "Must set @signal prefix on descendant class" if not @signal?
    return [@signal, name].join("::")
  
  loggedEmit: (signal, err, data, callback = () -> ) ->
    # TODO: add logging
    util.debug("[emit]: ", err, data)
    @emit(signal, err, data, callback)

module.exports = EE