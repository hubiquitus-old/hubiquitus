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
should = require("should")
describe "hSetFilter", ->
  hActor = undefined
  config = require("./_config")
  hResultStatus = require("../lib/codes").hResultStatus
  cmd = {}
  actorModule = require("../lib/actor/hactor")

  before () ->
    topology = {
    actor: config.logins[0].urn,
    type: "hactor"
    }
    hActor = actorModule.newActor(topology)

  after () ->
    hActor.h_tearDown()

  beforeEach (done) ->
    hActor.setFilter {}, (status, result) ->
      status.should.be.equal(hResultStatus.OK)
      done()


  it "should return hResult INVALID_ATTR if params filter is not an object", (done) ->
    hActor.setFilter "a string", (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "invalid filter"
      done()


  it "should return hResult INVALID_ATTR if filter does not start with a correct operand", (done) ->
    hCondition = bad:
      attribut: true

    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal("A filter must start with a valid operand")
      done()


  it "should return hResult INVALID_ATTR if filter with operand eq/ne/lt/lte/gt/gte/in/nin is not an object", (done) ->
    hCondition =
      eq: "string"
      ne: "string"
      lt: "string"
      lte: "string"
      gt: "string"
      gte: "string"
      in: "string"
      nin: "string"

    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "The attribute of an operand eq must be an object"
      done()


  it "should return hResult INVALID_ATTR if filter with operand and/or/nor is not an array", (done) ->
    hCondition =
      and:
        attribut: false

      or:
        attribut: false

      nor:
        attribut: false

    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "The attribute must be an array with at least 2 elements"
      done()


  it "should return hResult INVALID_ATTR if filter with operand and/or/nor is an array of 1 element", (done) ->
    hCondition =
      and: [attribut: false]
      or: [attribut: false]
      nor: [attribut: false]

    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "The attribute must be an array with at least 2 elements"
      done()


  it "should return hResult INVALID_ATTR if filter with operand not is an invalid object", (done) ->
    hCondition = not: [attribut: false]
    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "The attribute of an operand \"not\" must be an object"
      done()


  it "should return hResult INVALID_ATTR if filter with operand \"not\" doesn't contain valid operand", (done) ->
    hCondition = not:
      bad:
        attribut: false

    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "A filter must start with a valid operand"
      done()


  it "should return hResult INVALID_ATTR if filter with operand relevant is not a boolean", (done) ->
    hCondition = relevant: "string"
    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "The attribute of an operand \"relevant\" must be a boolean"
      done()


  it "should return hResult INVALID_ATTR if filter with operand geo have not attribut radius", (done) ->
    hCondition = geo:
      lat: 12
      lng: 24

    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "Attributes of an operand \"geo\" must be numbers"
      done()


  it "should return hResult INVALID_ATTR if filter with operand geo have not attribut lat", (done) ->
    hCondition = geo:
      lng: 24
      radius: 10000

    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "Attributes of an operand \"geo\" must be numbers"
      done()


  it "should return hResult INVALID_ATTR if filter with operand geo have not attribut lng", (done) ->
    hCondition = geo:
      lat: 12
      radius: 10000

    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "Attributes of an operand \"geo\" must be numbers"
      done()


  it "should return hResult INVALID_ATTR if attribut lat of filter geo is not a number", (done) ->
    hCondition = geo:
      lat: "string"
      lng: 24
      radius: 10000

    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "Attributes of an operand \"geo\" must be numbers"
      done()


  it "should return hResult INVALID_ATTR if attribut lng of filter geo is not a number", (done) ->
    hCondition = geo:
      lat: 12
      lng: "string"
      radius: 10000

    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "Attributes of an operand \"geo\" must be numbers"
      done()


  it "should return hResult INVALID_ATTR if attribut lat of filter geo is not a number", (done) ->
    hCondition = geo:
      lat: 12
      lng: 24
      radius: "string"

    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "Attributes of an operand \"geo\" must be numbers"
      done()


  it "should return INVALID_ATTR if attribute boolean is not a boolean", (done) ->
    hCondition = boolean: "string"
    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "The attribute of an operand \"boolean\" must be a boolean"
      done()

  it "should return INVALID_ATTR if attribute domain is not a string", (done) ->
    hCondition = domain:{hello:"world"}
    hActor.setFilter hCondition, (status, result) ->
      status.should.be.equal(hResultStatus.INVALID_ATTR)
      result.should.be.equal "The attribute of an operand \"domain\" must be a string"
      done()