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
mongo = require "mongodb"
_ = require "underscore"

#
# Class that defines a MongoDB Outbound Adapter.
#
class MongoOutboundAdapter extends OutboundAdapter

  # @property {object} MongoDB instance
  @dbInstance: undefined

  # @property {object} MongoDB client handle
  @mongoclient: undefined

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    properties.serializer = 'none'
    super
    @type = "mongo_out"

  #
  # @overload start()
  #   Method which start the adapter.
  #   When this adapter is started, the adapter can transmit hMessage
  #
  start: (callback)->
    mongo_host = @properties.host || "127.0.0.1"
    mongo_port = @properties.port || mongo.Connection.DEFAULT_PORT
    mongo_server_options = {auto_reconnect: true}
    mongo_dbname = @properties.name
    mongoserver = new mongo.Server(mongo_host, mongo_port, mongo_server_options)
    @mongoclient = new mongo.MongoClient(mongoserver);

    @mongoclient.open (err, mongoclient) =>
      @owner.log "trace", "Opened mongodb link"
      if err
        @owner.log "error", "Couldn't connect to mongodb. If connection infos are valid, pool should connect as soon as the server is available. Error : ", err
      @dbInstance = mongoclient.db mongo_dbname

      if @properties.user and @properties.password
        @dbInstance.authenticate @properties.user, @properties.password, (err, success) =>
          unless err
            if callback then callback() else @started = true
          else
            @owner.log "error", "Error authenticating to mongodb. If authentication infos are valid, it should authenticate when server is available : ", err
      else
        if callback then callback() else @started = true

  #
  # @overload stop()
  #   Method which stop the adapter.
  #   When this adapter is stopped, the actor will not transmit hMessage form this adapter anymore
  #
  stop: ->
    if @started
      @mongoclient.close (err, result) =>
        if err
          @owner.log "error", "Closed mongo link with errors : ", err
        else
          @owner.log "trace", "Closed mongo link"

  #
  # @overload h_send(buffer)
  #   Method which send the hMessage to the MongoDB collection.
  #   @param buffer {Buffer} The hMessage to send
  #
  h_send: (buffer) ->
    @start() unless @started

    if @dbInstance isnt undefined
      doc = buffer

      @dbInstance.collection(@properties.collection).save doc, {w: 1}, (err, savedDoc) =>
        if err
          @owner.log "error", "Error while saving hMessage in database", err
    else
      @owner.log "warn", "MongoDB not yet started"


module.exports = MongoOutboundAdapter
