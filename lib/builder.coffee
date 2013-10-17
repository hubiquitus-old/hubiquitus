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
# *   if not, see <http://opensource.org/licenses/mit-license.php>.
#

lodash = require "lodash"
UUID = require "./UUID"

#
# Builds hMessage
# @param actor {string} URN of the target of the hMessage
# @param type {string} Type of the hMessage
# @param payload {object} Content of the hMessage
# @param options {object} Optionals attributs of the hMessage
#
exports.message = (actor, type, payload, options) ->
  options = options or {}
  hMessage = {}
  #hMessage.publisher = @actor
  hMessage.msgid = UUID.generate()
  hMessage.published = hMessage.published or new Date().getTime()
  hMessage.actor = actor
  hMessage.ref = options.ref if options.ref
  hMessage.convid = options.convid if options.convid
  hMessage.type = type if type
  hMessage.priority = options.priority if options.priority
  hMessage.relevance = options.relevance if options.relevance
  if options.relevanceOffset
    currentDate = new Date().getTime()
    hMessage.relevance = new Date(currentDate + options.relevanceOffset).getTime()
  hMessage.persistent = options.persistent if options.persistent
  hMessage.location = options.location if options.location
  hMessage.author = options.author if options.author
  hMessage.published = options.published if options.published
  hMessage.headers = options.headers if options.headers
  hMessage.payload = payload if payload
  hMessage.timeout = options.timeout if options.timeout
  hMessage.sent = new Date().getTime()
  return hMessage

#
# Builds hCommand
# @param actor {string} URN of the target of the hMessage
# @param cmd {string} Type of the hCommand
# @param params {object} The parameters of the hCommand
# @param options {object} Optionals attributs of the hMessage
#
exports.command = (actor, cmd, params, options) ->
  params = params or {}
  options = options or {}
  hCommand = {cmd: cmd, params: params}
  return exports.message actor, "hCommand", hCommand, options

#
# Builds hResult
# @param actor {string} URN of the target of the hMessage
# @param ref {string} The msgid of the message refered to
# @param status {number} The status of the operation
# @param result {object, array, string, number, boolean} The result of a command operation
# @param options {object} Optionals attributs of the hMessage
#
exports.result = (actor, ref, status, result, options) ->
  options = options or {}
  hResult = {status: status, result: result}
  options.ref = ref
  return exports.message actor, "hResult", hResult, options

#
# Builds hSignal
# @param actor {string} URN of the target of the hMessage
# @param name {string} The name of the hSignal
# @param params {object} The parameters of the hSignal
# @param options {object} Optionals attributs of the hMessage
#
exports.signal = (actor, name, params, options) ->
  params = params or {}
  options = options or {}
  options.persistent = options.persistent or false
  hSignal = {name: name, params: params}
  return exports.message actor, "hSignal", hSignal, options
