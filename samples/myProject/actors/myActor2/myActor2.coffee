{Actor} = require "hubiquitus"

class myActor2 extends Actor

  constructor: (topology) ->
    super #This instruction is mandatory to correctly start your actor
    @type = 'myActor'

  onMessage: (hMessage) ->
    console.log "myActor2 receive a hMessage", hMessage

exports.myActor2 = myActor2
exports.newActor = (topology) ->
  new myActor2(topology)