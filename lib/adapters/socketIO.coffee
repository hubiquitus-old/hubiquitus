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
OutboundAdapter = require "./OutboundAdapter"

#
# Class that defines a socket-IO Adapter.
# It is used to communicate with the client using a hAPI
#
class SocketIOAdapter extends OutboundAdapter

  # @property {object} socket-io websocket
  sock: undefined

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    super
    @type = "socketIO"
    @sock = properties.socket
    @sock.identity = "socketIO_of_#{@owner.actor}"
    @sock.on "hMessage", (hMessage) =>
      @owner.emit "message", hMessage
    @started = true

  #
  # @overload send(hMessage)
  #   Method which send the hMessage in the socket-io websocket.
  #   @param hMessage {object} The hMessage to send
  #
  send: (hMessage) ->
    @sock.emit "hMessage", hMessage


module.exports = SocketIOAdapter
