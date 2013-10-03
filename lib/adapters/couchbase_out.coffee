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
couchbase = require "couchbase"
_ = require "underscore"

#
# Class that defines a Couchbase Outbound Adapter.
#
class CouchbaseOutboundAdapter extends OutboundAdapter

# @property {object} bucket instance
  @bucketInstance: undefined

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    properties.serializer = 'none'
    super
    @type = "couchbase_out"

  #
  # @overload start()
  #   Method which start the adapter.
  #   When this adapter is started, the adapter can transmit hMessage
  #
  start: (callback)->
    config =
      "debug" : @properties.debug || false
      "user" : @properties.user || "Administrator"
      "password" : @properties.password || "password"
      "hosts" : @properties.hosts || [ "localhost:8091" ]
      "bucket" : @properties.bucket || "default"

    couchbase.connect config, (err, cb) =>
      if (err)
        @owner.log "error", "Failed to connect to the cluster : " + err
      else
        @bucketInstance = cb
        @owner.log "debug", "couchbase started"
        if callback then callback() else @started = true

  #
  # @overload stop()
  #   Method which stop the adapter.
  #   When this adapter is stopped, the actor will not transmit hMessage form this adapter anymore
  #
  stop: ->
    if @started
      @bucketInstance.shutdown()
      @owner.log "debug", "couchbase closed"

  #
  # @overload h_send(buffer)
  #   Method which send the hMessage to the Couchbase bucket.
  #   @param buffer {Buffer} The hMessage to send
  #
  h_send: (buffer) ->
    @start() unless @started
    if @bucketInstance isnt undefined
      @bucketInstance.set buffer.msgid, buffer, (err, meta) =>
        if err
          @owner.log "error", "Error while saving hMessage in database : " + err + " meta : " + meta
    else
      @owner.log "warn", "couchbase not yet started"


module.exports = CouchbaseOutboundAdapter
