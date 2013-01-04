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

{Actor} = require "./hactor"
adapters = require "./../adapters"
zmq = require "zmq"
validator = require "./../validator"

class Dispatcher extends Actor

  constructor: (topology) ->
    super
    @workersAlias = "#{@actor}#workers"
    @addWorkers(topology.properties.workers)
    @nbWorkers = topology.properties.workers.nb

  addWorkers : (workerProps) ->
    dispatchingUrl = "tcp://127.0.0.1:#{Math.floor(Math.random() * 98)+3000}"
    @outboundAdapters.push adapters.adapter("lb_socket_out", { targetActorAid: @workersAlias, owner: @, url: dispatchingUrl })
    #@inboundAdapters.push adapters.inboundAdapter("lb_socket", { owner: @, url: dispatchingUrl })
    for i in [1..workerProps.nb]
      @log "debug", "Adding a new worker #{i}"
      @createChild workerProps.type, workerProps.method, actor: "urn:localhost:worker#{i}", adapters: [ { type: "lb_socket_in", url: dispatchingUrl }, { type: "socket_in", url: "tcp://127.0.0.1:#{Math.floor(Math.random() * 98)+3000}" }],

  onMessage: (hMessage) ->
    @log "Dispatcher received a hMessage to send to workers: #{JSON.stringify(hMessage)}"
    loadBalancing = Math.floor(Math.random() * @nbWorkers) + 1
    sender = hMessage.publisher
    msg = @buildMessage("#{@actor}/worker#{loadBalancing}", hMessage.type, hMessage.payload)
    msg.publisher = sender
    @send msg

exports.Dispatcher = Dispatcher
exports.newActor = (topology) ->
  new Dispatcher(topology)