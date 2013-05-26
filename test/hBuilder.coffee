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
config = require("./_config")

describe "builder", ->
  hActor = undefined
  Actor = require "../lib/actors/hactor"

  before () ->
    topology = {
      actor: config.logins[0].urn,
    }
    hActor = new Actor(topology)
  #
  # Because the throws are in another file, the condition should.throw() does not work.
  # Using instead: try-catch + should in the caught error
  #
  describe "#buildMessage()", ->
    actor = "chan"
    it "should throw an error if actor not provided", (done) ->
      try
        hActor.buildMessage()
      catch error
        should.exist error.message
        done()

    it "should create a message if actor provided", (done) ->
      try
        hActor.buildMessage actor
        done()


  describe "#buildMeasure()", ->
    actor = "chan"
    value = 10
    unit = "meter"
    it "should throw an error if nothing provided", (done) ->
      try
        hActor.buildMeasure()
      catch error
        should.exist error.message
        done()

    it "should throw an error if value not provided but actor provided", (done) ->
      try
        hActor.buildMeasure actor
      catch error
        should.exist error.message
        done()

    it "should throw an error if unit not provided but actor and value provided", (done) ->
      try
        hActor.buildMeasure actor, value
      catch error
        should.exist error.message
        done()

    it "should throw an error if actor not provided but value and unit provided", (done) ->
      try
        hActor.buildMeasure `undefined`, value, unit
      catch error
        should.exist error.message
        done()

    it "should throw an error if unit not provided but actor and unit provided", (done) ->
      try
        hActor.buildMeasure actor, `undefined`, unit
      catch error
        should.exist error.message
        done()

    it "should throw an error if unitis only provided", (done) ->
      try
        hActor.buildMeasure `undefined`, `undefined`, unit
      catch error
        should.exist error.message
        done()

    it "should create a measure if all provided", (done) ->
      try
        hActor.buildMessage actor, value, unit
        done()


  describe "#buildAck()", ->
    actor = "chan"
    ack = "recv"
    ref = "aRef"
    options = convid: "convid"
    it "should throw an error if nothing provided", (done) ->
      try
        hActor.buildAck()
      catch error
        should.exist error.message
        done()

    it "should throw an error if ref not provided but actor provided", (done) ->
      try
        hActor.buildAck actor
      catch error
        should.exist error.message
        done()

    it "should throw an error if ack not provided but actor and ref provided", (done) ->
      try
        hActor.buildAck actor, ack
      catch error
        done()

    it "should not throw an error if options not provided but actor, ref, ack provided", (done) ->
      try
        hActor.buildAck actor, ref, ack
        done()
      catch error
        console.log "error : ", error

    it "should create an ack if all provided", (done) ->
      try
        hActor.buildAck actor, ref, ack, options
        done()


  describe "#buildConvState()", ->
    actor = "chan"
    convid = "convid"
    status = "status"
    options = convid: "convidOpt"
    it "should throw an error if nothing provided", (done) ->
      try
        hActor.buildConvState()
      catch error
        should.exist error.message
        done()

    it "should throw an error if convid not provided but actor provided", (done) ->
      try
        hActor.buildConvState actor
      catch error
        should.exist error.message
        done()

    it "should throw an error if status not provided but actor, convid provided", (done) ->
      try
        hActor.buildConvState actor, convid
      catch error
        should.exist error.message
        done()

    it "should create a ConvState if only options not provided", (done) ->
      try
        hActor.buildConvState actor, convid, status
        done()

    it "should create a ConvState if all provided", (done) ->
      try
        hActor.buildConvState actor, convid, status, options
        done()


  describe "#buildAlert()", ->
    actor = "chan"
    alert = "alert"
    it "should throw an error if nothing provided", (done) ->
      try
        hActor.buildAlert()
      catch error
        should.exist error.message
        done()

    it "should throw an error if alert not provided but actor provided", (done) ->
      try
        hActor.buildAlert actor
      catch error
        should.exist error.message
        done()

    it "should create an ack if all provided", (done) ->
      try
        hActor.buildAlert actor, alert
        done()

