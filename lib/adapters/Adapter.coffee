
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

UUID = require "../UUID"
url = require "url"
factory = require "../factory"

#
# Class that defines an Adapter
#
class Adapter

  # @property {string} Direction of the socket
  direction: undefined

  # @property {boolean} Adapter's status
  started: undefined

  # @property {object} Adapter's properties
  properties: undefined

  # @property {Actor} Adapter's owner
  owner: undefined

  # @property {string} Url use by the adapter
  url: undefined

  # @property {Authenticator} Adapter's authenticator
  authenticator: undefined

  # @property {Array<Filter>} Adapter's filters
  filters: undefined

  # @property {Serializer} Adapter's serializer
  serializer: undefined

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    if properties.owner
      @owner = properties.owner
    else
      throw new Error "You must pass an actor as reference"

    @started = false
    @properties = properties.properties

    if properties.auth
      if typeof properties.auth is 'string'
        @authenticator = factory.make properties.auth
      else
        @authenticator = factory.make properties.auth.type, properties.auth.properties

    if properties.serializer
      if typeof properties.serializer is 'string'
        if properties.serializer isnt 'none'
          @serializer = factory.make properties.serializer
      else
        @serializer = factory.make properties.serializer.type, properties.serializer.properties
    else
      @serializer = factory.make 'json'

    @filters = [];
    if properties.filters
      properties.filters.forEach (filter) ->
        if typeof filter is 'string'
          @filters.push(factory.make filter)
        else
          @filters.push(factory.make filter.type, filter.properties)

  #
  # Method which set the url variable with correct format
  # @param url_string {string} Launch properties of the adapter
  #
  formatUrl: (url_string) ->
    if url_string
      url_props = url.parse url_string
      if url_props.port
        @url = url_string
      else
        url_props.port = @genListenPort()
        delete url_props.host
        @url = url.format(url_props)
    else
      port = @genListenPort()
      @url = "tcp://#{@owner.ip}:#{port}"

  #
  # Method wich generate a random listen port (between 3000 and 33000)
  #
  genListenPort: ->
    Math.floor(Math.random() * 30000) + 3000

  #
  # Method which start the adapter.
  # This method could be override to specified an actor
  #
  start: ->
    @started = true

  #
  # Method which stop the adapter.
  # This method could be override to specified an actor
  #
  stop: ->
    @started = false

  #
  # Method which update the adapter properties.
  # This method could be override to specified an actor
  # @param properties {object} new properties to apply on the adapter
  #
  update: (properties) ->
    # Function to overide if you need to update adapter's properties

  #
  # Method called to override some hMessage's attributs before sending
  # @private
  # @param hMessage {object} the hMessage update
  # @param callback {function} callback
  #
  h_fillMessage: (hMessage, callback) ->
    unless hMessage.sent
      hMessage.sent = new Date().getTime()
    unless hMessage.msgid
      hMessage.msgid = UUID.generate()
    callback null, hMessage

  #
  # Make an hMessage from decoded data and provided metadata
  # @param data {object, string, number, boolean} decoded data given by the adapter
  # @param metadata {object} data metadata provided by the adapter
  # @params callback {function} called once lock is acquire or an error occured
  # @options callback err {object, string} only defined if an error occcured
  # @options callback hMessage {object} Hmessage created from given data
  #
  makeHMessage: (data, metadata, callback) ->
    callback null, data

  #
  # Convert an hMessage to a data and metadata that can be sent by the adapter
  # @param hMessage {object} hMessage to send
  # @params callback {function} called once lock is acquire or an error occured
  # @options callback err {object, string} only defined if an error occcured
  # @options callback data {object, string, number, boolean} data extracted from hMessage
  # @options callback metadata {object} data metadata extracted from the hMessage
  #
  makeData: (hMessage, callback) ->
    callback null, hMessage, null




module.exports = Adapter
