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

#
# Class that defines a Codec
#
class Codec

  #
  # Codec's constructor
  #
  constructor: () ->

  #
  # @param data {object, string, number, boolean} to encode
  # @param metadata {object} data metadata
  # @param callback {function} callback
  # @options callback err {object, string} only defined if an error occcured
  # @options callback data {object, string, number, boolean} data extracted from message
  # @options callback metadata {object} metadata extracted from message
  #
  encode: (data, metadata, callback) ->

  #
  # @param buffer {Buffer} the data to decode
  # @param metadata {object} buffer metadata
  # @param callback {Function} callback
  # @options callback err {object, string} only defined if an error occcured
  # @options callback data {object, string, number, boolean} data converted from buffer
  # @options callback metadata {object} metadata extracted by the adapter
  #
  decode: (buffer, metadata, callback) ->


module.exports = Codec