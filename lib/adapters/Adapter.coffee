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

url = require "url"

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

  #
  # Adapter's constructor
  # @param properties {object} Launch properties of the adapter
  #
  constructor: (properties) ->
    @started = false
    @properties = properties.properties
    if properties.owner
      @owner = properties.owner
    else
      throw new Error "You must pass an actor as reference"

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

exports.Adapter = Adapter
