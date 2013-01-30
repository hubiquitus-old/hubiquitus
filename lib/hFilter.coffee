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
errors = require("./codes").errors
codes = require("./codes")
validator = require("./validator")
log = require("winston")

exports.checkFilterFormat = (hCondition) ->
  if not hCondition or (hCondition not instanceof Object)
    return {
      result: false
      error: "the filter is not a valid object"
    }
  next = undefined
  checkFormat = undefined
  if Object.getOwnPropertyNames(hCondition).length is 0
    return {
      result: true
      error: ""
    }

  for condition in Object.getOwnPropertyNames(hCondition)
    switch condition
      when "eq", "ne", "gt", "gt", "gte", "lt", "lte", "in", "nin"
        for key of hCondition
          if not hCondition[key] or not(hCondition[key] instanceof Object)
            return {
              result: false
              error: "The attribute of an operand " + key + " must be an object"
            }
      when "and", "or", "nor"
        next = hCondition.and or hCondition.or or hCondition.nor
        if next.length <= 1 or next.length is `undefined`
          return {
            result: false
            error: "The attribute must be an array with at least 2 elements"
          }

        for nextCondition in next
          checkFormat = exports.checkFilterFormat(nextCondition)
          if checkFormat.result is false
            return {
              result: false
              error: checkFormat.error
            }
      when "not"
        if not hCondition.not or not (hCondition.not instanceof Object) or hCondition.not.length isnt `undefined`
          return {
            result: false
            error: "The attribute of an operand \"not\" must be an object"
          }
        checkFormat = exports.checkFilterFormat(hCondition.not)
        if checkFormat.result is false
          return {
            result: false
            error: checkFormat.error
          }
      when "relevant"
        if typeof hCondition.relevant isnt "boolean"
          return {
            result: false
            error: "The attribute of an operand \"relevant\" must be a boolean"
          }
      when "geo"
        if typeof hCondition.geo.lat isnt "number" or typeof hCondition.geo.lng isnt "number" or typeof hCondition.geo.radius isnt "number"
          return {
            result: false
            error: "Attributes of an operand \"geo\" must be numbers"
          }
      when "boolean"
        if typeof hCondition.boolean isnt "boolean"
          return {
            result: false
            error: "The attribute of an operand \"boolean\" must be a boolean"
          }
      when "domain"
        if typeof hCondition.domain isnt "string"
          return {
            result: false
            error: "The attribute of an operand \"domain\" must be a string"
          }
      else
        return {
          result: false
          error: "A filter must start with a valid operand"
        }

  return {
    result: true
    error: ""
  }

exports.findPath = (element, tab) ->
  path = element
  while path isnt undefined
    if path[tab[0]] isnt undefined and path[tab[0]] isnt null
      path = path[tab[0]]
    else
      return path
    tab.shift()


exports.checkFilterValidity = (hMessage, hCondition, context) ->
  filter = undefined
  validate = []
  operand = undefined
  key = undefined
  checkValidity = undefined
  error = undefined
  filter = hCondition
  if Object.getOwnPropertyNames(filter).length > 0
    i = 0
    for condition in Object.getOwnPropertyNames(filter)
      switch condition
        when "eq"
          operand = []
          k = 0
          for key of filter.eq
            message = exports.findPath(hMessage, key.split("."))
            message = message.replace(/\/.*/, "")  if key is "publisher"
            if filter.eq[key] is message
              operand[k] = true
              k++
          if operand.length is Object.getOwnPropertyNames(filter.eq).length
            validate[i] =
              result: true
              error: ""
          else
            validate[i] =
              result: false
              error: "hCondition " + filter + " is not validate"

        when "ne"
          operand = []
          k = 0
          for key of filter.ne
            message = exports.findPath(hMessage, key.split("."))
            if message is hMessage
              return {
                result: false
                error: "Attribute not find in hMessage"
              }
            message = message.replace(/\/.*/, "")  if key is "publisher"
            if filter.ne[key] is message
              operand[k] = true
              k++
          if operand.length is 0
            validate[i] =
              result: true
              error: ""
          else
            validate[i] =
              result: false
              error: "hCondition " + filter + " is not validate"

        when "gt"
          operand = []
          k = 0
          for key of filter.gt
            message = exports.findPath(hMessage, key.split("."))
            if typeof filter.gt[key] isnt "number" and typeof hMessage[key] isnt "number"
              return {
                result: false
                error: "Attribut of operand \"gt\" must be a number"
              }
            if filter.gt[key] < message
              operand[k] = true
              k++
          if operand.length is Object.getOwnPropertyNames(filter.gt).length
            validate[i] =
              result: true
              error: ""
          else
            validate[i] =
              result: false
              error: "hCondition " + filter + " is not validate"

        when "gte"
          operand = []
          k = 0
          for key of filter.gte
            message = exports.findPath(hMessage, key.split("."))
            if typeof filter.gte[key] isnt "number" and typeof hMessage[key] isnt "number"
              return {
                result: false
                error: "Attribut of operand \"gte\" must be a number"
              }
            if filter.gte[key] <= message
              operand[k] = true
              k++
          if operand.length is Object.getOwnPropertyNames(filter.gte).length
            validate[i] =
              result: true
              error: ""
          else
            validate[i] =
              result: false
              error: "hCondition " + filter + " is not validate"

        when "lt"
          operand = []
          k = 0
          for key of filter.lt
            message = exports.findPath(hMessage, key.split("."))
            if typeof filter.lt[key] isnt "number" and typeof hMessage[key] isnt "number"
              return {
                result: false
                error: "Attribut of operand \"lt\" must be a number"
              }
            if filter.lt[key] > message
              operand[k] = true
              k++
          if operand.length is Object.getOwnPropertyNames(filter.lt).length
            validate[i] =
              result: true
              error: ""
          else
            validate[i] =
              result: false
              error: "hCondition " + filter + " is not validate"

        when "lte"
          operand = []
          k = 0
          for key of filter.lte
            message = exports.findPath(hMessage, key.split("."))
            if typeof filter.lte[key] isnt "number" and typeof hMessage[key] isnt "number"
              return {
                result: false
                error: "Attribut of operand \"lte\" must be a number"
              }
            if filter.lte[key] >= message
              operand[k] = true
              k++
          if operand.length is Object.getOwnPropertyNames(filter.lte).length
            validate[i] =
              result: true
              error: ""
          else
            validate[i] =
              result: false
              error: "hCondition " + filter + " is not validate"

        when "in"
          operand = []
          k = 0
          for key of filter.in
            message = exports.findPath(hMessage, key.split("."))
            if typeof filter.in[key] is "string"
              return {
              result: false
              error: "Attribute of operand "in" must be a object"
              }
            for condIn in filter.in[key]
              if key is "publisher"
                message = message.replace(/\/.*/, "")
              if condIn is message
                operand[k] = true
                k++

          if operand.length is Object.getOwnPropertyNames(filter.in).length
            validate[i] =
              result: true
              error: ""
          else
            validate[i] =
              result: false
              error: "hCondition " + filter + " is not validate"

        when "nin"
          operand = []
          k = 0
          for key of filter.nin
            message = exports.findPath(hMessage, key.split("."))
            if typeof filter.nin[key] is "string" or message is hMessage
              return {
              result: false
              error: "Attribute of operand "in" must be a object"
              }
            for condIn in filter.nin[key]
              if key is "publisher"
                message = message.replace(/\/.*/, "")
              if condIn is message
                operand[k] = true
                k++

          if operand.length is 0
            validate[i] =
              result: true
              error: ""
          else
            validate[i] =
              result: false
              error: "hCondition " + filter + " is not validate"

        when "and"
          operand = []
          checkValidity = `undefined`
          error = []
          k = 0
          if filter.and.length <= 1 or filter.and.length is `undefined`
            return {
              result: false
              error: "Attribut of operand \"and\" must be an array with at least 2 elements"
            }
          j = 0
          for condAnd in filter.and
            checkValidity = exports.checkFilterValidity(hMessage, condAnd, context)
            if checkValidity.result
              operand[k] = true
              k++
            else
              error.push condAnd

          if operand.length is filter.and.length
            validate[i] =
              result: true
              error: ""
          else
            validate[i] =
              result: false
              error: "hCondition " + error + " is not validate"

        when "nor"
          operand = []
          checkValidity = `undefined`
          error = []
          k = 0
          if filter.nor.length <= 1 or filter.nor.length is `undefined`
            return (
              result: false
              error: "Attribute of operand \"nor\" must be an array with at least 2 elements"
            )
          for condNor in filter.nor
            checkValidity = exports.checkFilterValidity(hMessage, condNor, context)
            if checkValidity.result
              operand[k] = true
              k++
              error.push condNor

          if operand.length is 0
            validate[i] =
              result: true
              error: ""
          else
            validate[i] =
              result: false
              error: "hCondition " + error + " is validate"

        when "or"
          operand = []
          checkValidity = `undefined`
          error = []
          k = 0
          if filter.or.length <= 1 or filter.or.length is `undefined`
            return (
              result: false
              error: "Attribute of operand \"or\" must be an array with at least 2 elements"
            )
          for condOr in filter.or
            checkValidity = exports.checkFilterValidity(hMessage, condOr, context)
            if checkValidity.result
              operand[k] = true
              k++
            else
              error.push condOr

          if operand.length > 0
            validate[i] =
              result: true
              error: ""
          else
            validate[i] =
              result: false
              error: "hCondition " + error + " is not validate"

        when "not"
          operand = []
          k = 0
          if Object.getOwnPropertyNames(filter.not).length is 0
            return (
              result: false
              error: "Attribute of operand \"not\" must be an object"
            )
          checkValidity = exports.checkFilterValidity(hMessage, filter.not, context)
          if checkValidity.result is false
            operand[k] = true
            k++

          if operand.length isnt 0
            validate[i] =
              result: true
              error: ""
          else
            validate[i] =
              result: false
              error: "hCondition " + filter.not + " is validate"

        when "relevant"
          if typeof filter.relevant isnt "boolean" and hMessage.relevance isnt "string"
            return (
              result: false
              error: "Attribute of operand \"relevant\" must be a boolean"
            )
          if filter.relevant is true
            if new Date().getTime() <= hMessage.relevance
              return {
                result: true
                error: ""
              }
            else
              return {
                result: false
                error: "hCondition " + filter + " is not validate"
              }
          else if new Date().getTime() > new Date(hMessage.relevance)
            return {
              result: true
              error: ""
            }
          else
            return {
              result: false
              error: "hCondition " + filter + " is not validate"
            }

        when "geo"
          #Adapted from http://www.movable-type.co.uk/scripts/latlong.html
          if not filter.geo.radius or typeof filter.geo.lat isnt "number" or typeof filter.geo.lng isnt "number" #Radius not set, lat or lng NaN, ignore test
            return {
              result: false
              error: "Invalid geo attribute in the filter"
            }

          #lat or lng do not exist in msg
          if not hMessage.location or typeof hMessage.location.pos.lat isnt "number" or typeof hMessage.location.pos.lng isnt "number"
            return {
              result: false
              error: "Invalid position attribute in the hMessage"
            }
          R = 6371 #Earth radius in KM
          latChecker = (filter.geo.lat * Math.PI / 180)
          lngChecker = (filter.geo.lng * Math.PI / 180)
          latToCheck = (hMessage.location.pos.lat * Math.PI / 180)
          lngToCheck = (hMessage.location.pos.lng * Math.PI / 180)
          dLat = latChecker - latToCheck
          dLon = lngChecker - lngToCheck
          a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(latChecker) * Math.cos(latToCheck) * Math.sin(dLon / 2) * Math.sin(dLon / 2)
          c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
          d = R * c
          checkgeo = Math.abs(d * 1000) <= filter.geo.radius

          if checkgeo
            return {
              result: true
              error: ""
            }
          else
            return {
              result: false
              error: "hCondition " + filter + " is not validate"
            }

        when "boolean"
          if typeof filter.boolean isnt "boolean"
            return {
              result: false
              error: "Attribute of operand \"boolean\" must be a boolean"
            }
          if filter.boolean is true
            return {
              result: true
              error: ""
            }
          else
            return {
              result: false
              error: "the user's filter refuse all hMessage"
            }

        when "domain"
          if typeof filter.domain isnt "string"
            return {
              result: false
              error: "Attribute of operand \"domain\" must be a string"
            }
          if filter.domain is "$mydomain"
            filter.domain = validator.splitURN(context.actor)[0]
          if filter.domain is validator.splitURN(hMessage.publisher)[0]
            return {
              result: true
              error: ""
            }
          else
            return {
              result: false
              error: "User does'nt accept hMessage from this domain"
            }


        else
          return {
            result: false
            error: "The filter is not valid"
          }
      i++

  if validate.length is 0
    return {
      result: true
      error: ""
    }
  else
    for valid in validate
      if valid.result is false
        return {
          result: false
          error: valid.error
        }
  return {
    result: true
    error: ""
  }