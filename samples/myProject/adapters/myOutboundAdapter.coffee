{OutboundAdapter} = require "../../../lib/hubiquitus"

class myOutboundAdapter extends OutboundAdapter

  constructor: (properties) ->
    super
  # Add your initializing instructions

  start: (done) ->
    unless @started
      # Add your starting instructions
      super
      if done then done()

  stop: ->
    if @started
      # Add your stopping instructions
      super

  #
  # @overload h_send(buffer)
  #
  h_send: (buffer) ->
    # Add your sending instruction

module.exports = myOutboundAdapter