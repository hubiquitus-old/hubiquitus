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
socketIO = require "../client_connector/socketio_connector"
zmq = require "zmq"
_ = require "underscore"
validator = require "./../validator"

class Gateway extends Actor

  constructor: (topology) ->
    super
    # Setting outbound adapters
    @type = 'gateway'
    if topology.properties.socketIOPort
      socketIO.socketIO({port: topology.properties.socketIOPort, owner: @})

  onMessage: (hMessage) ->
    if validator.getBareURN(hMessage.actor) isnt validator.getBareURN(@actor)
      @log "debug", "Gateway received a message to send to #{hMessage.actor}: #{JSON.stringify(hMessage)}"
      @send hMessage


exports.Gateway = Gateway
exports.newActor = (topology) ->
  new Gateway(topology)
