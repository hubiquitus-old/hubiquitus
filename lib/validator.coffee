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

codes = require("./codes").hResultStatus
log = require("winston")

###
Checks if an hMessage is correctly formatted and has all the correct attributes
@param hMessage - hMessage to validate
@param cb - Function (err, result) where err is from hResult.status or nothing and
result is a string or nothing
###
exports.validateHMessage = (hMessage, cb) ->
  if not hMessage or typeof hMessage isnt "object"
    return cb(codes.MISSING_ATTR, "invalid params object received")
  unless hMessage.actor
    return cb(codes.MISSING_ATTR, "missing actor attribute in hMessage")
  unless exports.validateURN(hMessage.actor)
    return cb(codes.INVALID_ATTR, "hMessages actor is invalid")
  if hMessage.type and typeof hMessage.type isnt "string"
    return cb(codes.INVALID_ATTR, "hMessage type is not a string")
  if hMessage.priority
    unless typeof hMessage.priority is "number"
      return cb(codes.INVALID_ATTR, "hMessage priority is not a number")
    if hMessage.priority > 5 or hMessage.priority < 0
      return cb(codes.INVALID_ATTR, "hMessage priority is not a valid constant")
  if hMessage.relevance
    hMessage.relevance = new Date(hMessage.relevance).getTime() #Sent as a string, convert back to date
    if hMessage.relevance is "Invalid Date"
      return cb(codes.INVALID_ATTR, "hMessage relevance is specified and is not a valid date object")
  if hMessage.persistent and typeof hMessage.persistent isnt "boolean"
    return cb(codes.INVALID_ATTR, "hMessage persistent is not a boolean")
  if hMessage.location and (hMessage.location not instanceof Object)
    return cb(codes.INVALID_ATTR, "hMessage location is not an Object")
  unless hMessage.publisher
    return cb(codes.MISSING_ATTR, "hMessage missing publisher")
  if hMessage.published
    hMessage.published = new Date(hMessage.published).getTime() #Sent as a string, convert back to date
    if hMessage.published is "Invalid Date"
      return cb(codes.INVALID_ATTR, "hMessage published is specified and is not a valid date object")
  if typeof hMessage.headers isnt "undefined" and (hMessage.headers not instanceof Object)
    return cb(codes.INVALID_ATTR, "invalid headers object received")
  if hMessage.headers
    if hMessage.headers.RELEVANCE_OFFSET and typeof hMessage.headers.RELEVANCE_OFFSET isnt "number"
      return cb(codes.INVALID_ATTR, "invalid RELEVANCE_OFFSET header received")
    if hMessage.headers.MAX_MSG_RETRIEVAL and typeof hMessage.headers.MAX_MSG_RETRIEVAL isnt "number"
      return cb(codes.INVALID_ATTR, "invalid MAX_MSG_RETRIEVAL header received")

  cb codes.OK

###
Returns true or false if it is a valid URN following hubiquitus standards
@param urn - the urn string to validate
###
exports.validateURN = (urn) ->
  /(^urn:[a-zA-Z0-9]{1}[a-zA-Z0-9\-.]+:[a-zA-Z0-9_,=@;!'%/#\(\)\+\-\.\$\*\?]+\/?.+$)/.test(urn)

###
Returns true or false if it is a valid URN with resource following hubiquitus standards
@param urn - the urn string to validate
###
exports.validateFullURN = (urn) ->
  /(^urn:[a-zA-Z0-9]{1}[a-zA-Z0-9\-.]+:[a-zA-Z0-9_,=@;!'%/#\(\)\+\-\.\$\*\?]+\/.+$)/.test(urn)

###
Removes attributes that are strings and that are empty (ie. "") in hLocation
@param obj - Object that has the object attributes
###
exports.cleanLocationAttrs = (obj) ->
  for key of obj
    if key is "pos"
      obj[key] = exports.cleanLocationAttrs(obj[key])
    if obj[key] is ""
      delete obj[key]
  obj

###
Removes attributes that are objects and do not have any attributes inside (removes empty objects).
It also removes attributes that are strings and that are empty (ie. "")
@param obj - Object that has the object attributes
@param attrs - Array with the names of the attributes that must be deleted from obj if empty.
###
exports.cleanEmptyAttrs = (obj, attrs) ->
  found = undefined

  for cleanAttr in attrs
    found = false

    # Search if object has attributes
    if obj[cleanAttr] instanceof Object
      for attr of obj[cleanAttr]
        if cleanAttr is "location"
          obj[cleanAttr] = exports.cleanLocationAttrs(obj[cleanAttr])
        if obj[cleanAttr].hasOwnProperty(attr)
          found = true
    else if typeof obj[cleanAttr] is "string" and obj[cleanAttr] isnt ""
      found = true

    unless found
      delete obj[attr]

  obj #Make it chainable

###
Splits a VALID URN in three parts: (user)(domain)(resource), the third part can be empty
@param urn - URN to split
###
exports.splitURN = (urn) ->
  splitted = urn.split(":")  if typeof urn is "string"
  if splitted
    if exports.validateFullURN(urn)
      splitted[3] = splitted[2].replace(/(^[^\/]*\/)/, "")
      splitted[2] = splitted[2].replace(/\/.*$/g, "")
    splitted.splice 1, 3
  else
    [`undefined`, `undefined`, `undefined`]

exports.getBareURN = (urn) ->
  urnParts = exports.splitURN(urn)
  "urn:" + urnParts[0] + ":" + urnParts[1]


###
Compares two URNs. Can use modifiers to ignore certain parts
@param urn1 - First URN to compare
@param urn2 - Second URN
@param mod - String with modifiers. Accepted:
r: considers resource
@return {Boolean} true if equal.
###
exports.compareURNs = (urn1, urn2, mod) ->
  return false  if not exports.validateURN(urn1) or not exports.validateURN(urn2)
  j1 = exports.splitURN(urn1)
  j2 = exports.splitURN(urn2)
  return false  if not j1 or not j2
  if /r/.test(mod)
    j1[0] is j2[0] and j1[1] is j2[1] and j1[2] is j2[2]
  else
    j1[0] is j2[0] and j1[1] is j2[1]


###
Returns the domain from a well formed URN, or null if domain not found.
@param urn - The bare/full URN to parse
@return a domain in the form of a string
###
exports.getDomainURN = (urn) ->
  exports.splitURN(urn)[0]