{Actor} = require "../../../lib/hubiquitus"

class myActor extends Actor

  constructor: (topology) ->
    super #This instruction is mandatory to correctly start your actor
    @type = 'myActor'

  onMessage: (hMessage, callback) ->
    console.log "myActor receive a hMessage", hMessage

module.exports = myActor
