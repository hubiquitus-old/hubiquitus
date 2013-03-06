{InboundAdapter} = require "hubiquitus"

class myInboundAdapter extends InboundAdapter

  constructor: (properties) ->
    super
  # Add your initializing instructions

  start: ->
    unless @started
      # Add your starting instructions
      @owner.emit "message", hMessage # To send the hMessage to the actor
      super

  stop: ->
    if @started
      # Add your stopping instructions
      super

exports.myInboundAdapter = myInboundAdapter
exports.newAdapter = (properties) ->
  new myInboundAdapter(properties)
