should = require("should")
fs = require ("fs")
Actor = require "../lib/actors/hactor"


describe "hFilewatchAdapter", ->
  hActor = undefined
  hActor2 = undefined
  topology = undefined


  describe "watch for modification in a file", ->

    before () ->

      topology = {
        actor: "urn:localhost:actor",
        type: "hactor",
        properties: {},
        adapters: [ { type: "filewatcherAdapter", properties: {path:"./test.json"}} ]
      }
      fs.writeFile("./test.json",'"111"')

      hActor = new Actor topology
      hMessage = hActor.h_buildSignal(hActor.actor, "start", {})
      hMessage.sent = new Date().getTime()
      hActor.h_onMessageInternal(hMessage)

    after () ->
      hActor.h_tearDown()
      hActor = null
      hActor2.h_tearDown()
      hActor2 = null
      fs.unlink("./test.json")

    it "Should send a hMessage if there is a modification in the file", (done) ->
      fs.writeFile("./test.json",'"222"')
      hActor.onMessage = (hMessage) ->
        hMessage.payload.should.be.equal("222")
        done()


    it "Should wait if the file is deleted and continue to watch when it is re-created ", (done) ->
      @timeout 1500
      fs.unlink("./test.json")
      setTimeout(=>
        fs.writeFile("./test.json",'"333"')
      , 500)

      hActor.onMessage = (hMessage) ->
        hMessage.payload.should.be.equal("333")
        done()



    it "Should do nothing if the file is not present when it start ", (done) ->
      @timeout 2000

      topology = {
        actor: "urn:localhost:actor",
        type: "hactor",
        properties: {},
        adapters: [ { type: "filewatcherAdapter", properties: {path:"./test2.json"}} ]
      }
      valid = 0

      hActor2 = new Actor topology

      hMessage = hActor2.h_buildSignal(hActor2.actor, "start", {})
      hMessage.sent = new Date().getTime()
      hActor2.h_onMessageInternal(hMessage)

      hActor2.onMessage = (hMessage) ->
        valid = 1


      setTimeout(=>
        valid.should.be.equal(0)
        done()
      , 1000)












