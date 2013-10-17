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
# *    or substantilal portions of the Software.
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
tv4 = require('tv4').tv4
schemas = require("./schemas")
lodash = require("lodash")

###
Checks if an hMessage is correctly formatted and has all the correct attributes
@param hMessage - hMessage to validate
result is an object
###
exports.validateHMessage = (hMessage, callback) ->
  result = tv4.validateResult(hMessage, schemas.hMessage)
  if lodash.isFunction(callback)
    if result.valid
      callback null, hMessage
    else
      callback result.error, null
  return result

###
Checks if a topology is correctly formatted and has all the correct attributes
@param topology - topology to validate
@param cb - Function (err, result) where err is from hResult.status or nothing and
result is a string or nothing
###
exports.validateTopology = (topology, callback) ->
  result = tv4.validateResult(topology, schemas.topology)
  if lodash.isFunction(callback)
    if result.valid
      callback null, topology
    else
      callback result.error, null
  return result

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

#
# ---------------------------------------- URN management - deprecated : see utils.urn
#

###
Returns true or false if it is a valid URN following hubiquitus standards
@param urn - the urn string to validate
@deprecated
###
exports.validateURN = (urn) ->
  /(^urn:[a-zA-Z0-9]{1}[a-zA-Z0-9\-.]+:[a-zA-Z0-9_,=@;!'%/#\(\)\+\-\.\$\*\?]+(\/.+)?$)/.test(urn)

###
Returns true or false if it is a valid URN with resource following hubiquitus standards
@param urn - the urn string to validate
@deprecated
###
exports.validateFullURN = (urn) ->
  /(^urn:[a-zA-Z0-9]{1}[a-zA-Z0-9\-.]+:[a-zA-Z0-9_,=@;!'%/#\(\)\+\-\.\$\*\?]+\/.+$)/.test(urn)

###
Splits a VALID URN in three parts: (user)(domain)(resource), the third part can be empty
@param urn - URN to split
@deprecated
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

###
Return the bare urn of an actor
@param urn - full URN
@deprecated
###
exports.getBareURN = (urn) ->
  urnParts = exports.splitURN(urn)
  "urn:" + urnParts[0] + ":" + urnParts[1]

###
Return the resource of an actor
@param urn - full URN
@deprecated
###
exports.getResource = (urn) ->
  if exports.validateFullURN(urn)
    urnParts = exports.splitURN(urn)
    urnParts[2]
  else
    "undefined"


###
Compares two URNs. Can use modifiers to ignore certain parts
@param urn1 - First URN to compare
@param urn2 - Second URN
@param mod - String with modifiers. Accepted:
r: considers resource
@return {Boolean} true if equal.
@deprecated
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
@deprecated
###
exports.getDomainURN = (urn) ->
  exports.splitURN(urn)[0]
