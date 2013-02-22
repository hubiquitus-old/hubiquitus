{Actor} = require "hubiquitus"

class myActor extends Actor

  constructor: (topology) ->
    super #This instruction is mandatory to correctly start your actor
    @type = 'myActor'

  onMessage: (hMessage) ->
    console.log "myActor receive a hMessage", hMessage

exports.myActor = myActor
exports.newActor = (topology) ->
  new myActor(topology)