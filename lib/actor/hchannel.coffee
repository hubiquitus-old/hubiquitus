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

{Actor} = require "./hactor"
adapters = require "./../adapters/hAdapters"
zmq = require "zmq"
_ = require "underscore"
validator = require "./../validator"
dbPool = require("./../dbPool.coffee").getDbPool()
codes = require "./../codes"
options = require("./../options").options

class Channel extends Actor

  constructor: (topology) ->
    #TODO Stop actor and send error when all mandatory attribut is not in topology
    super
    @actor = validator.getBareURN(topology.actor)
    @type = "channel"
    @inboundAdapters.push adapters.adapter("socket_in", {url: topology.properties.listenOn, owner: @})
    @outboundAdapters.push adapters.adapter("channel_out", {url: topology.properties.broadcastOn, owner: @, targetActorAid: @actor})
    @properties.subscribers = topology.properties.subscribers or []

  onMessage: (hMessage) ->
    # If hCommand, execute it
    if hMessage.type is "hCommand" and validator.getBareURN(hMessage.actor) is validator.getBareURN(@actor)
      switch hMessage.payload.cmd
        when "hGetLastMessages"
          command = require("./../hcommands/hGetLastMessages").Command
          module = new command()
          @runCommand(hMessage, module)
        when "hRelevantMessages"
          command = require("./../hcommands/hRelevantMessages").Command
          module = new command()
          @runCommand(hMessage, module)
        when "hGetThread"
          command = require("./../hcommands/hGetThread").Command
          module = new command()
          @runCommand(hMessage, module)
        when "hGetThreads"
          command = require("./../hcommands/hGetThreads").Command
          module = new command()
          @runCommand(hMessage, module)
        when "hSubscribe"
          command = require("./../hcommands/hSubscribe").Command
          module = new command()
          @runCommand(hMessage, module)
        else
          hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.NOT_AVAILABLE, "Command not available for this actor")
          @send hMessageResult
    # If other type, publish
    else
      if hMessage.persistent is true
        timeout = hMessage.timeout
        hMessage._id = hMessage.msgid

        delete hMessage.persistent
        delete hMessage.msgid
        delete hMessage.timeout

        dbPool.getDb @properties.db.dbName, (dbInstance) =>
          dbInstance.saveHMessage hMessage, @properties.db.dbCollection

        hMessage.persistent = true
        hMessage.msgid = hMessage._id
        hMessage.timeout = timeout
        delete hMessage._id

      #sends to all subscribers the message received
      hMessage.actor = @actor
      @send hMessage
      if hMessage.timeout > 0
        hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.OK, hMessage)
        @send hMessageResult

  h_onSignal: (hMessage) ->
    @log "debug", "Channel received a hSignal: #{JSON.stringify(hMessage)}"
    if hMessage.payload.name is "hStopAlert"
      hMessage.actor = @actor
      @send hMessage

  ###
  Loads the hCommand module, sets the listener.
  @param hMessage - The received hMessage with a hCommand payload
  @module Module calls to run command
  ###
  runCommand: (hMessage, module) ->
    self = this
    timerObject = null #setTimeout timer variable
    commandTimeout = null #Time in ms to wait to launch timeout
    hMessageResult = undefined
    hCommand = hMessage.payload

    #check hCommand
    if not hCommand or typeof hCommand isnt "object"
      @send self.buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.INVALID_ATTR, "Invalid payload. Not an hCommand")
      return
    if not hCommand.cmd or typeof hCommand.cmd isnt "string"
      @send self.buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.INVALID_ATTR, "Invalid command. Not a string")
      return
    if hCommand.params and typeof hCommand.params isnt "object"
      @send self.buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.INVALID_ATTR, "Invalid command. Params is settled but not an object")
      return
    commandTimeout = module.timeout or options["hcommands.timeout"]

    onResult = (status, result) =>
      #If callback is called after the timer ignore it
      return  unless timerObject?
      clearTimeout timerObject
      hMessageResult = self.buildResult(hMessage.publisher, hMessage.msgid, status, result)
      @log "debug", "hCommand sent hMessage with hResult", hMessageResult
      @send hMessageResult

    #Add a timeout for the execution
    timerObject = setTimeout(=>
      #Set it to null to test if send is executed after timeout
      timerObject = null
      hMessageResult = self.buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.EXEC_TIMEOUT,"")
      @log "debug", "hCommand sent hMessage with exceed timeout error", hMessageResult
      @send hMessageResult
    , commandTimeout)

    #Run it!
    try
      module.exec hMessage, @, onResult
    catch err
      clearTimeout timerObject
      @log "error", "Error in hCommand processing, hMessage = " + hMessage + " with error : " + err
      @send(@buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.TECH_ERROR, "error processing message : " + err))

  h_fillAttribut: (hMessage, cb) ->
    #Override with empty function to not altering hMessage

exports.Channel = Channel
exports.newActor = (properties) ->
  new Channel(properties)