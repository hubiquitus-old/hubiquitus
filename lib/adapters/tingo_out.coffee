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
tingo = require("tingodb")()

#
# Class that defines a TingoDB Outbound Adapter.
#
class TingoOutboundAdapter extends OutboundAdapter

  # @property {object} TingoDB database
  @tingoclient: undefined

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    properties.serializer = 'none'
    super
    @type = "tingo_out"

  #
  # @overload start()
  #   Method which start the adapter.
  #   When this adapter is started, the adapter can transmit hMessage
  #
  start: ->
    tingo_path = @properties.path
    tingoserver = {}
    @tingoclient = new tingo.Db(tingo_path, tingoserver)

    @tingoclient.open (err, tingoclient) =>
      @owner.log "trace", "Opened tingodb link"
      if err
        @owner.log "error", "Couldn't connect to tingodb. If connection infos are valid, pool should connect as soon as the server is available. Error : ", err
      else
        @owner.log "trace", "Opened !" + tingo_path

  #
  # @overload stop()
  #   Method which stop the adapter.
  #   When this adapter is stopped, the actor will not transmit hMessage form this adapter anymore
  #
  stop: ->
    if @started
      @tingoclient.close (err, result) =>
        if err
          @owner.log "error", "Closed tingo link with errors : ", err
        else
          @owner.log "trace", "Closed tingo link"

  #
  # @overload h_send(buffer)
  #   Method which send the hMessage to the TingoDB collection.
  #   @param buffer {Buffer} The hMessage to send
  #
  h_send: (buffer) ->
    @start() unless @started

    if @tingoclient isnt undefined
      doc = buffer

      @tingoclient.collection(@properties.collection).save doc, {w: 1}, (err, savedDoc) =>
        if err
          @owner.log "error", "Error while saving hMessage in database", err
        else
          @owner.log "trace", "Opened !" + @properties.collection
    else
      @owner.log "warn", "TingoDB not yet started"


module.exports = TingoOutboundAdapter
