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
url = require "url"
{Adapter} = require "./Adapter"

#
# Class that defines an Outbound adapter
#
class OutboundAdapter extends Adapter

  # @property {string}
  targetActorAid: undefined

  # @property {function} sendMessage
  prepareMessage: undefined

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    @direction = "out"
    if properties.targetActorAid
      @targetActorAid = properties.targetActorAid
    else
      throw new Error "You must provide the AID of the targeted actor"
    super

    args = [];
    @filters.forEach (filter) ->
      args.push filter.validate
    args.push validator.validateHMessage
    args.push @serializer.encode
    if @authenticator then args.push @authenticator.authorize

    @prepareMessage = async.compose.apply null, args.reverse()

  #
  # Method which has to be override to specify an outbound adapter
  # @param hMessage {object}
  #
  send: (hMessage) ->
    @prepareMessage hMessage, (err, buffer) =>
      if err
        @owner.log "error", JSON.stringify(err)
      else
        @h_send buffer

  #
  # Method which has to be override to specify an outbound adapter
  # @param buffer {buffer}
  #
  h_send: (buffer) ->
    throw new Error "Send method should be overriden"


exports.OutboundAdapter = OutboundAdapter
