{Actor} = require "../../../lib/hubiquitus"

class myActor extends Actor

  constructor: (topology) ->
    super #This instruction is mandatory to correctly start your actor
    @type = 'myActor'

  onMessage: (hMessage, callback) ->
    @log "debug", "myActor receive a hMessage", hMessage

    if hMessage.type is "hCommand" and hMessage.payload.cmd is "POST"
      msg = @buildResult hMessage.publisher, hMessage.msgid, 0, {"hello":"hello"}
      @log "debug", "sending response : ", msg
      callback msg

module.exports = myActor
