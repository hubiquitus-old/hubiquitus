#
# * Copyright (c) Novedia Group 2012.
# *
# *    This file is part of Hubiquitus
# *
# *    Permission is hereby granted, free of charge, to any person obtaining a copy
# *    of this software and associated documentation files (the "Software"), to deal
# *    in the Software without restriction, including without limitation the rights
# *    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# *    of the Software, and to permit persons to whom the Software is furnished to do so,
# *    subject to the following conditions:
# *
# *    The above copyright notice and this permission notice shall be included in all copies
# *    or substantial portions of the Software.
# *
# *    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# *    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# *    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# *    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# *    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# *
# *    You should have received a copy of the MIT License along with Hubiquitus.
# *    If not, see <http://opensource.org/licenses/mit-license.php>.
#
{InboundAdapter} = require "./InboundAdapter"
zmq = require "zmq"

#
# Class that defines a Socket LoadBalancing Inbound Adapter.
# It is used when a actor is one of the load balance actor.
#
class LBSocketInboundAdapter extends InboundAdapter

  # @property {object} zeromq socket
  sock: undefined

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    super
    @formatUrl(properties.url)
    @type = "lb_socket_in"

  #
  # Method which initialize the zmq pull load balancing socket
  #
  initSocket: () ->
    @sock = zmq.socket "pull"
    @sock.identity = "LBSocketIA_of_#{@owner.actor}"
    @sock.on "message", @receive
  #
  # @overload start()
  #   Method which start the adapter.
  #   When this adapter is started, the actor will receive some hMessage depending the load balancing
  #
  start: ->
    @initSocket()
    while @started is false
      try
        @sock.connect @url
        @owner.log "debug", "#{@sock.identity} listening on #{@url}"
        super
      catch err
        if err.message is "Address already in use"
          @sock = null
          @initSocket()
          @formatUrl @url.replace(/:[0-9]{4,5}$/, '')
          @owner.log "info", 'Change listening port to avoid collision :', err

  #
  # @overload stop()
  #   Method which stop the adapter.
  #   When this adapter is stopped, the actor will not receive hMessage from this adapter anymore
  #
  stop: ->
    if @started
      if @sock._zmq.state is 0
        @sock.close()
      super
      @sock.on "message", ()=>
      @sock = null


module.exports = LBSocketInboundAdapter
