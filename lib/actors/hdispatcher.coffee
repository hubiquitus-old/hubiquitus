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

Actor = require "./hactor"
factory = require "../hfactory"
zmq = require "zmq"
validator = require "../validator"

#
# Class that defines a dispatcher actor
#
class Dispatcher extends Actor

  # @property {String} URN use by the dispatcher to talk to his workers
  workersAlias: undefined
  # @property {Integer} Number of workers create by the dispatcher
  nbWorkers: undefined

  #
  # Actor's constructor
  # @param topology {object} Launch topology of the actor
  #
  constructor: (topology) ->
    super
    @type = 'dispatcher'
    @workersAlias = "#{@actor}#workers"
    @addWorkers(topology.properties.workers)
    @nbWorkers = topology.properties.workers.nb

  #
  # Method which create the workers
  # @param workerProps {object} Properties of workers which the dispatcher launch (method, type and nb)
  #
  addWorkers : (workerProps) ->
    dispatchingUrl = "tcp://127.0.0.1:#{Math.floor(Math.random() * 98)+3000}"
    @outboundAdapters.push factory.newAdapter("lb_socket_out", { targetActorAid: @workersAlias, owner: @, url: dispatchingUrl })
    #@inboundAdapters.push adapters.inboundAdapter("lb_socket", { owner: @, url: dispatchingUrl })
    for i in [1..workerProps.nb]
      @log "debug", "Adding a new worker #{i}"
      @createChild workerProps.type, workerProps.method, actor: "urn:localhost:worker#{i}", adapters: [ { type: "lb_socket_in", url: dispatchingUrl }, { type: "socket_in", url: "tcp://127.0.0.1:#{Math.floor(Math.random() * 98)+3000}" }],

  #
  # @overload onMessage(hMessage)
  #   Method that processes the incoming message on a hDispatcher.
  #   @param hMessage {Object} the hMessage receive
  #
  onMessage: (hMessage) ->
    @log "Dispatcher received a hMessage to send to workers: #{JSON.stringify(hMessage)}"
    loadBalancing = Math.floor(Math.random() * @nbWorkers) + 1
    sender = hMessage.publisher
    msg = @buildMessage("#{@actor}/worker#{loadBalancing}", hMessage.type, hMessage.payload)
    msg.publisher = sender
    @send msg

  #
  # @overload h_fillAttribut(hMessage, cb)
  #   Method called to override some hMessage's attributs before sending.
  #   Overload the hActor method with an empty function to not altering a hMessage publish in a channel
  #   @private
  #
  h_fillAttribut: (hMessage, cb) ->
    #Override with empty function to not altering hMessage


module.exports = Dispatcher
