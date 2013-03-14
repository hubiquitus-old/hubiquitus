{OutboundAdapter} = require "hubiquitus"

class myOutboundAdapter extends OutboundAdapter

  constructor: (properties) ->
    super
  # Add your initializing instructions

  start: ->
    unless @started
      # Add your starting instructions
      super

  stop: ->
    if @started
      # Add your stopping instructions
      super

  send: (message) ->
    # Add your sending instruction

exports.myOutboundAdapter = myOutboundAdapter
exports.newAdapter = (properties) ->
  new myOutboundAdapter(properties)