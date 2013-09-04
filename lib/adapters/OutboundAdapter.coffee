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
Adapter = require "./Adapter"

#
# Class that defines an Outbound adapter
#
class OutboundAdapter extends Adapter

  # @property {string}
  targetActorAid: undefined

  # @property {function} sendMessage
  prepareMessage: undefined

  # @property {boolean} Adapter's status
  starting: undefined

  # @property {Array} Waiting queue
  queue: undefined

  # @property {function} onMessage
  onMessage: undefined

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    @starting = false
    @queue = []
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
    args.push @makeData
    if @codec then args.push @codec.encode
    if @authenticator then args.push @authenticator.authorize

    @prepareMessage = async.compose.apply null, args.reverse()

    args = [];
    if @authenticator then args.push @authenticator.authorize
    if @codec then args.push @codec.decode
    args.push @makeHMessage
    args.push @h_fillMessage
    args.push validator.validateHMessage
    @filters.forEach (filter) ->
      args.push filter.validate

    @onMessage = async.compose.apply null, args.reverse()

  #
  # Internal method, used to send a message, and queue it if adapter is not ready
  # @param hMessage {object}
  #
  h_send: (hMessage) ->
    unless @started
      @queue.push hMessage
      unless @starting
        @starting = true
        @start () =>
          @started = true
          @starting = false
          while hMessage = @queue.pop()
            @h_send hMessage
    else
      @prepareMessage hMessage, (err, buffer, metadata) =>
        unless err
          @send buffer, metadata
        else
          @owner.log "error", err

  #
  # @param buffer {buffer}
  #
  receive: (buffer, metadata) =>
    @onMessage buffer, metadata, (err, hMessage) =>
      if err
        @owner.log "error", err
      else
        @owner.emit "message", hMessage

  #
  # Method which has to be override to specify an outbound adapter
  # @param buffer {buffer}
  # @param metadata {object} metadata extracted from hMessage
  #
  send: (buffer, metadata) ->
    throw new Error "Send method should be overriden"


module.exports = OutboundAdapter
