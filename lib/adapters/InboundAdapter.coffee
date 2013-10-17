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

async = require 'async'
validator = require "../validator"
Adapter = require "./Adapter"

#
# Class that defines an Inbound adapter
#
class InboundAdapter extends Adapter

  # @property {function} onMessage
  onMessage: undefined

  # @property {function} onMessage
  reply: undefined

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    super
    @direction = "in"

    args = []
    if @authenticator then args.push @authenticator.authorize
    if @codec then args.push @codec.decode
    args.push @makeHMessage
    args.push @h_fillMessage
    args.push validator.validateHMessage
    @filters.forEach (filter) ->
      args.push filter.validate

    @onMessage = async.compose.apply null, args.reverse()

    args = []
    args.push @h_fillMessage
    args.push validator.validateHMessage
    args.push @makeData
    if @codec then args.push @codec.encode

    @reply = async.compose.apply null, args.reverse()

  #
  # @param buffer {buffer}
  #
  receive: (buffer, metadata, callback) =>
    @onMessage buffer, metadata, (err, hMessage) =>
      if err
        return @owner._h_makeLog "error", "hub-120", {msg: "adapter onMessage error", hMessage: hMessage, err: err}
      if callback
        @owner._h_onHMessage hMessage, (hMessageResult) =>
          if not hMessageResult then return
          hMessageResult.ref = hMessage.msgid
          @reply hMessageResult, (err, buffer, metadata) ->
            if err
              return @owner._h_makeLog "error", "hub-121", {hMessageResult: hMessageResult, err: err}
            callback buffer, metadata
      else
        @owner._h_onHMessage hMessage

module.exports = InboundAdapter
