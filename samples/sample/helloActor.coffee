{Actor} = require "../../lib/hubiquitus"

class HelloActor extends Actor

  constructor: (topology) ->
    super #This instruction is mandatory to correctly start your actor
    @type = 'helloActor'

  onMessage: (hMessage, callback) ->
    @info "HelloActor receives a message", hMessage
    response = @buildResult hMessage.publisher, hMessage.msgid, 0, {"hello": "world"}
    @info "HelloActor sends a response", response
    callback response

module.exports = HelloActor
