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

Actor = require "./hactor"
zmq = require "zmq"
_ = require "underscore"
os = require "os"
statuses = require("../codes").statuses
errors = require("../codes").errors
validator = require "../validator"
codes = require "../codes"
hFilter = require "../hFilter"
factory = require "../factory"
UUID = require "../UUID"

#
# Class that defines a session actor
#
class Session extends Actor

  # @property {String} Inbound Adapter of the gateway which create the session
  trackInbox: undefined
  # @property {Object} Socket-IO client which link the hAPI and the hEngine
  hClient: undefined

  #
  # Actor's constructor
  # @param topology {object} Launch topology of the actor
  #
  constructor: (topology) ->
    super
    # Setting outbound adapters
    @type = 'session'
    @trackInbox = topology.trackInbox
    @hClient = undefined

  #
  # @overload _h_touchTracker()
  #   Method called every minuts to inform the tracker about the actor state.
  #   The session give his gateway address until his own
  #   @private
  #
  _h_touchTracker: ->
    if not @tracker then return

    @_h_makeLog "trace", "hub-114", {actor: @actor, tracker: @tracker}, "touching tracker #{@tracker.trackerId}"

    if @status is "stopping"
      @trackInbox = []

    @send @h_buildSignal(@tracker.trackerId, "peer-info", {
      peerType: @type
      peerId: validator.getBareURN(@actor)
      peerStatus: @status
      peerInbox: @trackInbox
      peerIP: @ip
      peerPID: process.pid
      peerMemory: process.memoryUsage()
      peerUptime: process.uptime()
      peerLoadAvg: os.loadavg()
      peerResource: validator.getResource(@actor)
    })

  #
  # @overload validateFilter(hMessage)
  #   Method called on incoming message to check if the hMessage respect the actor's filter
  #   If the message is send by the hAPI he always be accepted.
  #   @param hMessage {object} hMessage to check with the actor's filter
  #
  #
  validateFilter: (hMessage) ->
    unless validator.getBareURN(hMessage.publisher) is validator.getBareURN(@actor)
      return hFilter.checkFilterValidity(hMessage, @filter, {actor:@actor})
    return {result: true, error: ""}

  #
  # @overload h_onMessageInternal(hMessage)
  #   Method called when the actor receive a hMessage.
  #   If the actor attribute is "session", it will be modify with the actor URN
  #   Check hMessage format, catch hSignal, Apply filter then call onMessage.
  #   @private
  #   @param hMessage {object} the hMessage receive
  #
  h_onMessageInternal: (hMessage) ->
    if hMessage.actor is "session"
      hMessage.actor = @actor
    super

  #
  # @overload onMessage(hMessage)
  #   Method that processes the incoming message on a hSession.
  #   @param hMessage {Object} the hMessage receive
  #
  onMessage: (hMessage) ->
    # If hCommand, execute it
    if hMessage.type is "hCommand" and validator.getBareURN(hMessage.actor) is validator.getBareURN(@actor) and hMessage.publisher is @actor
      switch hMessage.payload.cmd
        when "hSetFilter"
          @setFilter hMessage.payload.params, (status, result) =>
            hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, status, result)
            @send hMessageResult
        when "hUnsubscribe"
          @unsubscribe hMessage.payload.params.channel, (status, result) =>
            hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, status, result)
            @send hMessageResult
        when "hGetSubscriptions"
          hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.OK, @getSubscriptions())
          @send hMessageResult
        else
          hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.NOT_AVAILABLE, "Command not available for this actor")
          @send hMessageResult
    else if hMessage.actor is @actor
      @hClient.emit "hMessage", hMessage
    else
      if hMessage.type is "hCommand"
        switch hMessage.payload.cmd
          when "hSubscribe"
            @subscribe hMessage.actor, "", (status, result) =>
              hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, status, result)
              @send hMessageResult
          else
            hMessage.publisher = @actor
            @log "trace", "Session received a hCommand to send to #{hMessage.actor}:", hMessage
            if hMessage.timeout > 0
              @send hMessage, (hResult) =>
                @hClient.emit "hMessage", hResult
            else
              @send hMessage
      else
        hMessage.publisher = @actor
        @log "debug", "Session received a hMessage to send to #{hMessage.actor}: #{JSON.stringify(hMessage)}"
        if hMessage.timeout > 0
          @send hMessage, (hResult) =>
            @hClient.emit "hMessage", hResult
        else
          @send hMessage

  #
  # Method that Loads the hCommand module, sets the listener.
  # @param hMessage {object} The received hMessage with a hCommand payload
  # @param module {object} Module calls to run command
  #
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
    commandTimeout = module.timeout or 5000

    onResult = (status, result) =>
      #If callback is called after the timer ignore it
      return  unless timerObject?
      clearTimeout timerObject
      hMessageResult = self.buildResult(hMessage.publisher, hMessage.msgid, status, result)
      self.log "debug", "hCommand sent hMessage with hResult", hMessageResult
      @send hMessageResult

    #Add a timeout for the execution
    timerObject = setTimeout(=>
      #Set it to null to test if cb is executed after timeout
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
      @log "error", "Error in hCommand processing, hMessage = ", hMessage, " with error : ", err
      @send(self.buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.TECH_ERROR, "error processing message : " + err))

  #
  # Method called to link the client who use an hAPI and the hSession
  # @param client {object} The socket-IO client
  #
  initListener: (client) ->
    delete client["hClient"]
    socketIOAdapter = factory.make("socketIO", {targetActorAid: @actor, owner: @, socket: client.socket})
    @hClient = client.socket

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

  # @overload h_fillAttribut(hMessage, cb)
  #   Method called to override some hMessage's attributs before sending in any cases.
  #   @private
  #   @param hMessage {object} the hMessage update
  #   @param cb {function}
  #
  h_fillAttribut: (hMessage, cb) ->
    #Complete hMessage
    hMessage.publisher = @actor
    hMessage.msgid = hMessage.msgid or UUID.generate()
    hMessage.sent = new Date().getTime()


module.exports = Session
