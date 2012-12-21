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
zmq = require "zmq"
_ = require "underscore"
statuses = require("../codes").statuses
errors = require("../codes").errors
validator = require "../validator"
codes = require "../codes"
options = require "../options"
hFilter = require "../hFilter"
adapters = require "../adapters"


class Session extends Actor

  constructor: (properties) ->
    super
    # Setting outbound adapters
    @type = 'session'
    @trackInbox = properties.trackInbox

  touchTrackers: ->
    _.forEach @trackers, (trackerProps) =>
      @log "debug", "touching tracker #{trackerProps.trackerId}"
      if @status is "stopping"
        @trackInbox = []
      @send @buildSignal(trackerProps.trackerId, "peer-info", {peerType:@type, peerId:validator.getBareURN(@actor), peerStatus:@status, peerInbox:@trackInbox})

  checkFilter: (hMessage) ->
    unless validator.getBareURN(hMessage.publisher) is validator.getBareURN(@actor)
      return hFilter.checkFilterValidity(hMessage, @filter)
    return {result: true, error: ""}

  onMessage: (hMessage, cb) ->
    # If hCommand, execute it
    if hMessage.type is "hCommand" and validator.getBareURN(hMessage.actor) is validator.getBareURN(@actor)
      switch hMessage.payload.cmd
        when "hCreateUpdateChannel"
          command = require("./../hcommands/hCreateUpdateChannel").Command
          module = new command()
          @runCommand(hMessage, module, cb)
        when "hEcho"
          command = require("./../hcommands/hEcho").Command
          module = new command()
          @runCommand(hMessage, module, cb)
        when "hSetFilter"
          @setFilter hMessage.payload.params, (status, result) =>
            hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, status, result)
            cb hMessageResult
        else
          hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.NOT_AVAILABLE, "Command not available for this actor")
          cb hMessageResult
    else if hMessage.actor is @actor
      @send hMessage
    else
      if hMessage.type is "hCommand"
        switch hMessage.payload.cmd
          when "hSubscribe"
            @subscribe hMessage.actor, "", (status, result) =>
              hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, status, result)
              cb hMessageResult
          when "hUnsubscribe"
            @h_unsubscribe hMessage.actor, (status, result) =>
              hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, status, result)
              cb hMessageResult
          else
            hMessage.publisher = @actor
            @log "debug", "Session received a hCommand to send to #{hMessage.actor}: #{JSON.stringify(hMessage)}"
            @send hMessage
      else
        hMessage.publisher = @actor
        @log "debug", "Session received a hMessage to send to #{hMessage.actor}: #{JSON.stringify(hMessage)}"
        @send hMessage

  ###
  Loads the hCommand module, sets the listener calls cb with the hResult.
  @param hMessage - The received hMessage with a hCommand payload
  @param cb - Callback receiving a hResult (optional)
  ###
  runCommand: (hMessage, module, cb) ->
    self = this
    timerObject = null #setTimeout timer variable
    commandTimeout = null #Time in ms to wait to launch timeout
    hMessageResult = undefined
    hCommand = hMessage.payload

    #check hCommand
    if not hCommand or typeof hCommand isnt "object"
      cb self.buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.INVALID_ATTR, "Invalid payload. Not an hCommand")
      return
    if not hCommand.cmd or typeof hCommand.cmd isnt "string"
      cb self.buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.INVALID_ATTR, "Invalid command. Not a string")
      return
    if hCommand.params and typeof hCommand.params isnt "object"
      cb self.buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.INVALID_ATTR, "Invalid command. Params is settled but not an object")
      return
    commandTimeout = module.timeout or options.commandController.timeout

    onResult = (status, result) ->
      #If callback is called after the timer ignore it
      return  unless timerObject?
      clearTimeout timerObject
      hMessageResult = self.buildResult(hMessage.publisher, hMessage.msgid, status, result)
      self.log "debug", "hCommand sent hMessage with hResult", hMessageResult
      cb hMessageResult

    #Add a timeout for the execution
    timerObject = setTimeout(->
      #Set it to null to test if cb is executed after timeout
      timerObject = null
      hMessageResult = self.buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.EXEC_TIMEOUT,"")
      @log "debug", "hCommand sent hMessage with exceed timeout error", hMessageResult
      cb hMessageResult
    , commandTimeout)

    #Run it!
    try
      module.exec hMessage, @, onResult
    catch err
      clearTimeout timerObject
      @log "error", "Error in hCommand processing, hMessage = " + hMessage + " with error : " + err
      cb(self.buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.TECH_ERROR, "error processing message : " + err))

  initListener: (client) =>
    delete client["hClient"]
    socketIOAdapter = adapters.socketIOAdapter({targetActorAid: @actor, owner: @, socket: client.socket})
    @outboundAdapters.push socketIOAdapter

    @on "hStatus", (msg) ->
      client.socket.emit "hStatus", msg

    @on "connect", ->
      client.publisher = @actor
      client.socket.emit "attrs",
        publisher: @actor
        sid: client.id

      #Start listening for client actions
      socketIOAdapter.start()

    @on "disconnect", ->
      @emit "hStatus", {status:statuses.DISCONNECTING, errorCode:errors.NO_ERROR}
      @h_tearDown()
    #Start listening for messages from Session and relaying them
    #client.hClient.on "hMessage", (hMessage) ->
    #  log.info "Sent message to client " + client.id, hMessage
    #  client.socket.emit "hMessage", hMessage
    @emit "hStatus", {status:statuses.CONNECTED, errorCode:errors.NO_ERROR}
    @emit "connect"

exports.Session = Session
exports.newActor = (properties) ->
  new Session(properties)