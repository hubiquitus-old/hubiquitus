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
SocketIO_Connector = require "../client_connector/socketio_connector"
zmq = require "zmq"
_ = require "underscore"
validator = require "../validator"

#
# Class that defines a gateway actor
#
class Gateway extends Actor

  #
  # Actor's constructor
  # @param topology {object} Launch topology of the actor
  #
  constructor: (topology) ->
    super
    # Setting outbound adapters
    @type = 'gateway'
    if topology.properties.socketIOPort
      new SocketIO_Connector({port: topology.properties.socketIOPort, owner: @, security: topology.properties.security})

  #
  # @overload onMessage(hMessage)
  #   Method that processes the incoming message on a hGateway.
  #   @param hMessage {Object} the hMessage receive
  #
  onMessage: (hMessage) ->
    if validator.getBareURN(hMessage.actor) isnt validator.getBareURN(@actor)
      @log "trace", "Gateway received a message to send to #{hMessage.actor}:", hMessage
      @send hMessage

  #
  # @overload h_fillAttribut(hMessage, cb)
  #   Method called to override some hMessage's attributs before sending.
  #   Overload the hActor method with an empty function to not altering a hMessage publish in a channel
  #   @private
  #
  h_fillAttribut: (hMessage, cb) ->
    #Override with empty function to not altering hMessage
    hMessage.sent = new Date().getTime()


module.exports = Gateway
