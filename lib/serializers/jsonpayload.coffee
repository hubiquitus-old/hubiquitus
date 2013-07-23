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
Serializer = require "./hserializer"
#
# Class that defines a JSONPayload Serializer
#
class JSONPayload extends Serializer

  #
  # JSONPayload Serializer's constructor
  # This Serializer encode a hMessage in a payload or decode a payload in a hMessage
  #
  constructor: () ->

  #
  # @param hMessage {object} the payload to encode
  # @param callback {function} callback
  #
  encode: (hMessage, callback) ->
    try
      payload = JSON.stringify(hMessage.payload)
      callback null, new Buffer(payload, "utf-8")
    catch err
      callback err, null

  #
  # @param buffer {Buffer} the payload to decode
  # Build and have a hMessage for callback
  #
  decode: (buffer, callback) ->
    try
      payloadStr = buffer.toString("utf-8")
      payload = JSON.parse(payloadStr)
      hMessage = {msgid: UUID.generate(), type:"jsonPayload", payload:payload}

      callback null, hMessage
    catch err
      callback err, null

  #
  # Generator of MSGID of the hMessage
  #
  #
UUID = ->
UUID.generate = ->
    a = UUID._gri
    b = UUID._ha
    b(a(32), 8) + "-" + b(a(16), 4) + "-" + b(16384 | a(12), 4) + "-" + b(32768 | a(14), 4) + "-" + b(a(48), 12)
UUID._gri = (a) ->
    (if 0 > a then NaN else (if 30 >= a then 0 | Math.random() * (1 << a) else (if 53 >= a then (0 | 1073741824 * Math.random()) + 1073741824 * (0 | Math.random() * (1 << a - 30)) else NaN)))

UUID._ha = (a, b) ->
    c = a.toString(16)
    d = b - c.length
    e = "0"

    while 0 < d
      d & 1 and (c = e + c)
      d >>>= 1
      e += e
    c

module.exports = JSONPayload
