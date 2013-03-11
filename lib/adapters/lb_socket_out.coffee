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
{OutboundAdapter} = require "./hadapter"
zmq = require "zmq"


class LBSocketOutboundAdapter extends OutboundAdapter

  # @property {object} zeromq socket
  sock: undefined

  constructor: (properties) ->
    super
    if properties.url
      @url = properties.url
    else
      throw new Error "You must explicitely pass a valid url to a LBSocketOutboundAdapter"

  initsocket: ->
    @sock = zmq.socket "push"
    @sock.identity = "LBSocketOA_of_#{@owner.actor}_to_#{@targetActorAid}"

  start:->
    @initsocket()
    @sock.bindSync @url
    @owner.log "debug", "#{@sock.identity} bound on #{@url}"
    super

  stop: ->
    if @started
      if @sock._zmq.state is 0
        @sock.close()
      super
      @sock.on "message",()=>
      @sock=null

  send: (message) ->
    @start() unless @started
    @sock.send JSON.stringify(message)


exports.LBSocketOutboundAdapter = LBSocketOutboundAdapter
exports.newAdapter = (properties) ->
  new LBSocketOutboundAdapter properties
