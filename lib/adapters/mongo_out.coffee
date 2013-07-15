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

{OutboundAdapter} = require "./OutboundAdapter"
mongo = require "mongodb"
_ = require "underscore"

#
# Class that defines a MongoDB Outbound Adapter.
#
class MongoOutboundAdapter extends OutboundAdapter

  # @property {object} MongoDB instance
  @dbInstance: undefined

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    properties.serializer = 'none'
    super
    @type = "mongo_out"

  #
  # Method called to connect to the mongoDB database.
  # @private
  #
  h_connectToDatabase: () ->
    #Create the Server and the DB to access mongo
    new mongo.Db(@properties.name, new mongo.Server(@properties.host or 'localhost', @properties.port or 27017), {safe: false}).open (err, dbOpen) =>
      unless err
        @owner.log "debug", "Correctly connect to mongo"
        @dbInstance = dbOpen

        if @properties.user and @properties.password
          @dbInstance.authenticate @properties.user, @properties.password, (err, success) =>
            if err
              @owner.log "error", err

        #Error opening database
      else
        @owner.log "error", "Could not open database"

  #
  # @overload start()
  #   Method which start the adapter.
  #   When this adapter is started, the adapter can transmit hMessage
  #
  start: ->
    @h_connectToDatabase()
    super

  #
  # @overload stop()
  #   Method which stop the adapter.
  #   When this adapter is stopped, the actor will not transmit hMessage form this adapter anymore
  #
  stop: ->
    if @started
      @dbInstance.close()

  #
  # @overload h_send(buffer)
  #   Method which send the hMessage to the MongoDB collection.
  #   @param buffer {Buffer} The hMessage to send
  #
  h_send: (buffer) ->
    @start() unless @started

    if @dbInstance isnt undefined
      doc = _.omit buffer, 'msgid'
      doc._id = buffer.msgid

      @dbInstance.collection(@properties.collection).save doc, {safe:true}, (err, res) =>
        if err
          @owner.log "error", "Error while save hMessage in database"
    else
      @owner.log "warn", "MongoDB not yet started"


module.exports = MongoOutboundAdapter
