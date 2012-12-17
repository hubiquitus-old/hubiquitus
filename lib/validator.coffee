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

codes = require("./codes.coffee").hResultStatus
log = require("winston")
dbPool = require("./dbPool.coffee").getDbPool()

exports.validateHChannel = (hChannel, cb) ->
  i = undefined
  required = ["type", "_id", "owner", "subscribers", "active"]

  #Test if object exists
  unless hChannel instanceof Object
    return cb(codes.INVALID_ATTR, "invalid object received")

  #Test required attributes
  for attribute in required
    if not hChannel[attribute]? or hChannel[attribute] is `undefined`
      return cb(codes.MISSING_ATTR, "missing attribute " + attribute)

  #Test if correct format/ correct values
  if hChannel._id and typeof hChannel._id isnt "string"
    return cb(codes.INVALID_ATTR, "actor is not a string")
  unless exports.isChannel(hChannel._id)
    return cb(codes.INVALID_ATTR, "actor not valid " + hChannel._id)
  if /^#hAdminChannel@/.test(hChannel._id)
    return cb(codes.NOT_AUTHORIZED, "using reserved keyword " + hChannel._id + " as actor")
  if hChannel.chdesc and typeof hChannel.chdesc isnt "string"
    return cb(codes.INVALID_ATTR, "chdesc is not a string")
  if typeof hChannel.priority isnt "undefined"
    if typeof hChannel.priority isnt "number"
      return cb(codes.INVALID_ATTR, "priority not a number")
    if hChannel.priority < 0 or hChannel.priority > 5
      return cb(codes.INVALID_ATTR, "priority is has not a valid value")
  if hChannel.type isnt "channel"
    return cb(codes.INVALID_ATTR, "type attribute is not 'channel'")
  if typeof hChannel.location isnt "undefined" and (hChannel.location not instanceof Object)
    return cb(codes.INVALID_ATTR, "location not an object")
  unless exports.validateJID(hChannel.owner)
    return cb(codes.INVALID_ATTR, "owner is not a string")
  if exports.splitJID(hChannel.owner)[2]
    return cb(codes.INVALID_ATTR, "owner is not a bare jid")
  unless hChannel.subscribers instanceof Array
    return cb(codes.INVALID_ATTR, "subscribers is not an array")
  for subscriber in hChannel.subscribers
    if typeof subscriber isnt "string"
      return cb(codes.INVALID_ATTR, "subscriber " + i + " is not a JID")
    if not exports.validateJID(subscriber) or exports.splitJID(subscriber)[2]
      return cb(codes.INVALID_ATTR, "subscriber " + i + " is not a JID")
  if typeof hChannel.active isnt "boolean"
    return cb(codes.INVALID_ATTR, "active is not a boolean")
  if typeof hChannel.headers isnt "undefined" and (hChannel.headers not instanceof Object)
    return cb(codes.INVALID_ATTR, "invalid headers object received")
  if hChannel.actor isnt hChannel.publisher
    return cb status.NOT_AUTHORIZED, "You cannot create a channel for this actor"
  cb codes.OK

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
  unless exports.validateJID(hMessage.actor)
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
  if hMessage.author and not exports.validateJID(hMessage.author)
    return cb(codes.INVALID_ATTR, "hMessage author is not a JID")
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
Returns true or false if it is a valid JID following hubiquitus standards
@param jid - the jid string to validate
###
exports.validateJID = (jid) ->
  #/(^[^@\/<>'"]+(@.+|$)|^[^#@]((?!@).)*$)/.test jid
  new RegExp("^(?:([^@/<>'\"]+)@)([^@/<>'\"]+)(?:/([^/<>'\"]*))?$").test jid
###
Returns true or false if it is a valid JID with ressource following hubiquitus standards
@param jid - the jid string to validate
###
exports.validateFullJID = (jid) ->
  /(^[^@\/<>'"]+(@.+\/.*|$)|^[^#@]((?!@).)*\/.*$)/.test jid

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
Tests if the given jid is that of a channel. This does not test if the channel is valid
or the domain.
@param jid
@return {Boolean} true if it's a channel
###
exports.isChannel = (jid) ->
  /(^#[^@\/<>'"]+(@.+|$)|^[^#@]((?!@).)*$)/.test jid


###
Splits a VALID JID in three parts: (user)(domain)(resource), the third part can be empty
@param jid - JID to split
###
exports.splitJID = (jid) ->
  splitted = jid.match(new RegExp("^(?:([^@/<>'\"]+)@)([^@/<>'\"]+)(?:/([^/<>'\"]*))?$"))  if typeof jid is "string"
  (if splitted then splitted.splice(1, 3) else [`undefined`, `undefined`, `undefined`])

exports.getBareJID = (jid) ->
  jidParts = exports.splitJID(jid)
  jidParts[0] + "@" + jidParts[1]


###
Compares two JIDs. Can use modifiers to ignore certain parts
@param jid1 - First JID to compare
@param jid2 - Second JID
@param mod - String with modifiers. Accepted:
r: considers resource
@return {Boolean} true if equal.
###
exports.compareJIDs = (jid1, jid2, mod) ->
  return false  if not exports.validateJID(jid1) or not exports.validateJID(jid2)
  j1 = exports.splitJID(jid1)
  j2 = exports.splitJID(jid2)
  return false  if not j1 or not j2
  if /r/.test(mod)
    j1[0] is j2[0] and j1[1] is j2[1] and j1[2] is j2[2]
  else
    j1[0] is j2[0] and j1[1] is j2[1]


###
Returns the domain from a well formed JID, or null if domain not found.
@param jid - The bare/full JID to parse
@return a domain in the form of a string
###
exports.getDomainJID = (jid) ->
  exports.splitJID(jid)[1]