should = require("should")
fs = require ("fs")
Actor = require "../lib/actors/hchannel"
couchbase = require "couchbase"


describe "hCouchbase_out", ->
  hActor = undefined
  topology = undefined
  user = "Administrator"
  password = "password"
  bucket = "test"


  describe "adapter couchbase to store hmessages", ->

    before () ->

      topology = {
        "actor": "urn:localhost:channel",
        "type": "hchannel",
        "method": "inproc",
        "properties": {
          "subscribers": [],
          "persistentAid": "urn:localhost:couchbase"
        },
        "adapters": [{
          "type": "couchbase_out",
          "targetActorAid": "urn:localhost:couchbase",
          "properties": {
            "user": "Administrator",
            "password": "password",
            "bucket": bucket
          }
        }]
      }

      hActor = new Actor topology
      hMessage = hActor.h_buildSignal(hActor.actor, "start", {})
      hMessage.sent = new Date().getTime()
      hActor.h_onMessageInternal(hMessage)

    after () ->
      hActor.h_tearDown()
      hActor = null


    it "Should store a hMessage in couchbase", (done) ->
      @timeout 3000
      hMessage2 = hActor.buildMessage(hActor.actor, "message", {"data":"dataToStore"})
      hMessage2.persistent = true
      hMessage2.sent = new Date().getTime()
      hActor.onMessage(hMessage2)
      setTimeout(=>
        config =
          "debug" : false
          "user" : "Administrator"
          "password" : "password"
          "hosts" : [ "localhost:8091" ]
          "bucket" : "test"
        couchbase.connect config, (err, cb) =>
          if (err)
            console.log "error", "Failed to connect to the cluster : " + err
          else
            cb.get hMessage2.msgid, (err, meta) =>
              if err
                console.log "erreur " + err
              meta.msgid.should.be.equal(hMessage2.msgid)
              done()
      , 500)

