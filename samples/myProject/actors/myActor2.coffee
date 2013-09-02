{Actor} = require "../../../lib/hubiquitus"

class myActor2 extends Actor

  constructor: (topology) ->
    super #This instruction is mandatory to correctly start your actor
    @type = 'myActor'

  onMessage: (hMessage, callback) ->
    @log "debug", "myActor2 receive a hMessage", hMessage

module.exports = myActor2