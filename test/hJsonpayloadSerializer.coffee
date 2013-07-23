should = require("should")
jsonpayload = require("../lib/serializers/jsonpayload")

describe "hJsonpayloadSerializer", ->
  jsonPayload = undefined

  describe "Serialized and deserialized a string", ->

    before () ->

      jsonPayload = new jsonpayload

    after () ->

      jsonPayload = null

    it "Should convert a string to a hMessage ", (done) ->
      fileContent = '{"content" : "file content"}'

      jsonPayload.decode fileContent,(err, result) =>

        result.should.not.be.null
        result.payload.content.should.be.equal("file content")

        done()

    it "Should convert the content of a hMessage to a string ", (done) ->

      hMessage = {msgid: "uuid", publisher:"", actor:"", type:"jsonPayload", payload:{content : "file content"}}

      jsonPayload.encode hMessage,(err, result) =>
        result.should.not.be.null
        result.toString().should.be.equal(new Buffer('{"content":"file content"}', "utf-8").toString())

        done()



