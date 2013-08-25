{InboundAdapter} = require "../../../lib/hubiquitus"

class myInboundAdapter extends InboundAdapter

  constructor: (properties) ->
    super
  # Add your initializing instructions
    @hMessage =
      actor: @owner.actor
      type: "string"
      publisher: @owner.actor
      published: new Date().getTime()

  start: ->
    unless @started
      # Add your starting instructions
      @receive (new Buffer(JSON.stringify(@hMessage), "utf-8")) # To send the hMessage to the actor
      super

  stop: ->
    if @started
      # Add your stopping instructions
      super

module.exports = myInboundAdapter
