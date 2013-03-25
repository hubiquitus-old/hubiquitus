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

# Node modules
{EventEmitter} = require "events"
forker = require "child_process"
# Third party modules
zmq = require "zmq"
winston = require "winston"
_ = require "underscore"
os = require "os"
# Hactor modules
validator = require "../validator"
codes = require "../codes"
hFilter = require "./../hFilter"
factory = require "../hfactory"

_.mixin toDict: (arr, key) ->
  throw new Error('_.toDict takes an Array') unless _.isArray arr
  _.reduce arr, ((dict, obj) ->
    dict[ obj[key] ] = obj if obj[key]?
    return dict), {}

#
# Class that defines an Actor
#
class Actor extends EventEmitter

  # Possible running states of an actor : Actor start and it isn'n available yet. It can't accept messages
  STATUS_STARTING = "starting"
  # Possible running states of an actor : Actor is not fully available. It can only accept direct message (send with fullURN)
  STATUS_STARTED = "started"
  # Possible running states of an actor : Actor stop and it isn't available anymore.
  STATUS_STOPPED = "stopped"
  # Possible running states of an actor : Actor is ready and fully available
  STATUS_READY = "ready"
  # Possible running states of an actor : Actor is in error. It accept direct message (send with fullURN) but there are no garanty that it can treat them.
  STATUS_ERROR = "error"

  # Native Actors provided by hubiquitus. If forked they will be used
  H_ACTORS =
    hauth: true
    hchannel: true
    hdispatcher: true
    hgateway: true
    hsession: true
    htracker: true
    hactor: true

  # @property {object} Contains the log properties object. It will be transfer to every children
  log_properties: undefined
  # @property {object} The instance of the logger use to display logs
  logger: undefined
  # @property {string} Actor's ID in URN format (with resource)
  actor: undefined
  # @property {string} Resource of the actor's URN
  resource: undefined
  # @property {string} Type of the hActor
  type: undefined
  # @property {object} The filter to use on incoming message
  filter: undefined
  # @property {object} Contains the callback to call on incoming hResult
  msgToBeAnswered: undefined
  # @property {object} Contains the timeout launch to forget an outbound adapter if it not use
  timerOutAdapter: undefined
  # @property {object} Contains the id and message of actor's errors
  error: undefined
  # @property {object} Interval set between 2 touchTrackers
  timerTouch: undefined
  # @property {Actor} The actor which create this actor
  parent: undefined
  # @property {number} Delay between 2 touchTrackers
  touchDelay: undefined
  # @property {object} Properties shared between an actor and his children
  sharedProperties: undefined
  # @property {object} Properties of the actor
  properties: undefined
  # @property {string} State of the actor
  status: undefined
  # @property {Array} List of topology of the actor's children
  children: undefined
  # @property {Array} Properties of the trackers which watch the actor
  trackers: undefined
  # @property {Array} List all the actor's inbound adapter
  inboundAdapters: undefined
  # @property {Array} List all the actor's outbound adapter
  outboundAdapters: undefined
  # @property {Array} List all the channel that the actor has subscribed
  subscriptions: undefined
  # @property {Array} List all subscribe command the actor have to launch after start
  channelToSubscribe: undefined
  # @property {Array} Describes which adapters watch which peer
  watchingsTab: undefined
  # @property {object} Topology the actor is launched with
  topology: undefined
  # @property {boolean} Wether listeners are already inited
  listenersInited: undefined



  #
  # Actor's constructor
  # @param topology {object} Launch topology of the actor
  #
  constructor: (topology) ->
    # init logger
    if topology.log
      @log_properties = topology.log
      @h_initLogger(topology.log.logLevel or "info", topology.log.logFile)
    else
      @log_properties =
        logLevel: "info"
      @h_initLogger("info")

    # setting up instance attributes
    if(validator.validateFullURN(topology.actor))
      @actor = topology.actor
    else if(validator.validateURN(topology.actor))
      @actor = "#{topology.actor}/#{UUID.generate()}"
    else
      throw new Error "Invalid actor URN"
    @resource = @actor.replace(/^.*\//, "")
    @type = "actor"
    @filter = {}
    if topology.filter
      @setFilter topology.filter, (status, result) =>
        unless status is codes.hResultStatus.OK
          # TODO arreter l'acteur
          @log "debug", "Invalid filter stopping actor"

    # Initializing class variables
    @msgToBeAnswered = {}
    @timerOutAdapter = {}
    @error = {}
    @touchDelay = 60000

    # Initializing attributs
    @status = STATUS_STOPPED
    @sharedProperties = topology.sharedProperties or {}
    # Deep copy JSON object (value only, no reference)
    @properties = JSON.parse(JSON.stringify(@sharedProperties)) or {}
    for prop of topology.properties
      @properties[prop] = topology.properties[prop]
    @children = []
    @trackers = []
    @inboundAdapters = []
    @outboundAdapters = []
    @subscriptions = []
    @channelToSubscribe = []
    @watchingsTab = []
    @topology = topology
    @listenersInited = false

    # Registering trackers
    if _.isArray(topology.trackers) and topology.trackers.length > 0
      _.forEach topology.trackers, (trackerProps) =>
        @log "debug", "registering tracker #{trackerProps.trackerId}"
        @trackers.push trackerProps
        @outboundAdapters.push factory.newAdapter("socket_out", {owner: @, targetActorAid: trackerProps.trackerId, url: trackerProps.trackerUrl})
    else
      @log "debug", "no tracker was provided"

    @h_initListeners()

    # Setting adapters
    _.forEach topology.adapters, (adapterProps) =>
      adapterProps.owner = @
      if adapterProps.type is 'channel_in'
        @channelToSubscribe.push adapterProps
      else
        adapter = factory.newAdapter(adapterProps.type, adapterProps)
        if adapter.direction is "in"
          @inboundAdapters.push adapter
        else if adapter.direction is "out"
          @outboundAdapters.push adapter

  #
  # Init Listeners for node.js events
  # @private
  #
  h_initListeners : () ->
    unless @listenersInited
      @listenersInited = true
      @on "message", (hMessage) =>
        #complete msgid
        if hMessage.msgid
          hMessage.msgid = hMessage.msgid + "#" + @h_makeMsgId()
        else
          hMessage.msgid = @h_makeMsgId()
        ref = undefined
        if hMessage and hMessage.ref and typeof hMessage.ref is "string"
          ref = hMessage.ref.split("#")[0]
        if ref
          cb = @msgToBeAnswered[ref]
        if cb
          delete @msgToBeAnswered[ref]
          cb hMessage
        else
          @h_onMessageInternal hMessage, (hMessageResult) =>
            @send hMessageResult

      # Adding children once started
      @on "hStatus", (status) ->
        if status is "started"
          @initChildren(@topology.children)

  #
  # Private method called when the actor receive a hMessage.
  # Check hMessage format, catch hSignal, Apply filter then call onMessage
  # @private
  # @param hMessage {object} the hMessage receive
  #
  h_onMessageInternal: (hMessage) ->
    @log "debug", "onMessage :" + JSON.stringify(hMessage)
    try
      validator.validateHMessage hMessage, (err, result) =>
        if err
          @log "debug", "hMessage not conform : " + JSON.stringify(result)
          hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.MISSING_ATTR, "actor is missing")
          @send hMessageResult
        else
          #Complete missing values
          hMessage.convid = (if not hMessage.convid or hMessage.convid is hMessage.msgid then hMessage.msgid else hMessage.convid)
          hMessage.published = hMessage.published or new Date().getTime()

          #Empty location and headers should not be sent/saved.
          validator.cleanEmptyAttrs hMessage, ["headers", "location"]

          if hMessage.type is "hSignal" and validator.getBareURN(hMessage.actor) is validator.getBareURN(@actor)
            switch hMessage.payload.name
              when "start"
                @h_start()
              when "stop"
                @h_tearDown()
              else
                @h_onSignal(hMessage)
          else
            #Check if hMessage respect filter
            checkValidity = @validateFilter(hMessage)
            if checkValidity.result is true
              @onMessage hMessage
            else
              @log "debug", "#{@actor} Rejecting a message because its filtered :" + JSON.stringify(hMessage)

    catch error
      @log "warn", "An error occured while processing incoming message: " + error

  #
  # Method that processes the incoming message.
  # This method could be override to specified an actor
  # @param hMessage {Object} the hMessage receive
  #
  onMessage: (hMessage) ->
    @log "debug", "Message reveived: #{JSON.stringify(hMessage)}"
    if hMessage.timeout > 0
        hMessageResult = @buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.NOT_AVAILABLE, "This actor doesn't answer")
        @send hMessageResult

  #
  # Private method that processes hSignal message.
  # The hSignal are service's message
  # @private
  # @param hMessage {object} the hSignal receive
  #
  h_onSignal: (hMessage) ->
    @log "debug", "Actor received a hSignal: #{JSON.stringify(hMessage)}"
    if hMessage.payload.name is "hStopAlert"
      @removePeer hMessage.payload.params
      index = -1
      inboundAdapterToRemove = _.find @inboundAdapters, (inbound) =>
        index++
        inbound.channel is validator.getBareURN hMessage.payload.params
      if inboundAdapterToRemove isnt undefined
        inboundAdapterToRemove.stop()

  #
  # Method called for sending hMessage
  # Check for an outboundAdapter, then ask to the tracker if needed
  # This method could be override to specified an actor
  # @param hMessage {object} the hMessage to send
  # @param cb {function} callback to call when a answer is receive
  # @option cb hResult {object} hMessage with hResult payload
  #
  send: (hMessage, cb) ->
    unless _.isString(hMessage.actor)
      if cb
        cb @buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.MISSING_ATTR, "actor is missing")
        return
      else
        throw new Error "'aid' parameter must be a string"

    # first looking up for a cached adapter
    outboundAdapter = _.toDict(@outboundAdapters, "targetActorAid")[hMessage.actor]
    unless outboundAdapter
      _.forEach @outboundAdapters, (outbound) =>
        if validator.getBareURN(outbound.targetActorAid) is validator.getBareURN(hMessage.actor)
          hMessage.actor = outbound.targetActorAid
          outboundAdapter = outbound
    if outboundAdapter
      if @timerOutAdapter[outboundAdapter.targetActorAid]
        clearTimeout(@timerOutAdapter[outboundAdapter.targetActorAid])
        @timerOutAdapter[outboundAdapter.targetActorAid] = setTimeout(=>
          outboundAdapter.stop()
        , 90000)
      @h_sending(hMessage, cb, outboundAdapter)
      # if don't have cached adapter, send lookup demand to the tracker
    else
      if @trackers[0]
        msg = @h_buildSignal(@trackers[0].trackerId, "peer-search", {actor: hMessage.actor}, {timeout: 5000})
        @send msg, (hResult) =>
          if hResult.payload.status is codes.hResultStatus.OK
            # Subscribe to trackChannel to be alerting when actor disconnect
            found = false
            _.forEach @outboundAdapters, (outbound) =>
              if outbound.targetActorAid is hResult.payload.result.targetActorAid
                found = true
                hMessage.actor = outbound.targetActorAid
                outboundAdapter = outbound
            unless found
              outboundAdapter = factory.newAdapter(hResult.payload.result.type, { targetActorAid: hResult.payload.result.targetActorAid, owner: @, url: hResult.payload.result.url })
              @outboundAdapters.push outboundAdapter
            @timerOutAdapter[outboundAdapter.targetActorAid] = setTimeout(=>
              outboundAdapter.stop()
            , 90000)
            hMessage.actor = hResult.payload.result.targetActorAid
            @h_sending hMessage, cb, outboundAdapter
          else
            if cb
              cb @buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.NOT_AVAILABLE, "Can't send hMessage : " + hResult.payload.result)
            else
              @log "debug", "Can't send hMessage : " + hResult.payload.result
      else
        if cb
          cb @buildResult(hMessage.publisher, hMessage.msgid, codes.hResultStatus.NOT_AVAILABLE, "Can't find actor")
          return
        else
          throw new Error "Don't have any tracker for peer-searching"

  #
  # Private method called for sending hMessage
  # Complete hMessage by override some attribut, then send the hMessage from outboundAdapter
  # @private
  # @param hMessage {object} the hMessage to send
  # @param cb {function} callback to call when a answer is receive
  # @option cb hResult {object} hMessage with hResult payload
  # @param outboundAdapter {object} adapter used to send hMessage
  #
  h_sending: (hMessage, cb, outboundAdapter) ->
    @h_fillAttribut(hMessage, cb)

    errorCode = undefined
    errorMsg = undefined

    #Verify if well formatted
    unless hMessage.actor
      errorCode = codes.hResultStatus.MISSING_ATTR
      errorMsg = "the actor attribute is missing"

    unless errorCode
      #if there is a callback and no timeout, timeout is set to default value of 30s
      #Add it to the open message to call cb later
      if cb
        if hMessage.timeout > 0
          @msgToBeAnswered[hMessage.msgid] = cb
          timeout = hMessage.timeout
          self = this

          #if no response in time we call a timeout
          setTimeout (->
            if self.msgToBeAnswered[hMessage.msgid]
              delete self.msgToBeAnswered[hMessage.msgid]
              errCode = codes.hResultStatus.EXEC_TIMEOUT
              errMsg = "No response was received within the " + timeout + " timeout"
              resultMsg = self.buildResult(hMessage.publisher, hMessage.msgid, errCode, errMsg)
              cb resultMsg
          ), timeout
        else
          hMessage.timeout = 0

      #Send it to transport
      @log "debug", "Sending message: #{JSON.stringify(hMessage)}"
      outboundAdapter.send hMessage
    else if cb
      actor = hMessage.actor or "Unknown"
      resultMsg = @buildResult(actor, hMessage.msgid, errorCode, errorMsg)
      cb resultMsg

  #
  # Method called to override some hMessage's attributs before sending
  # @private
  # @param hMessage {object} the hMessage update
  # @param cb {function} callback to define which attribut must be override
  #
  h_fillAttribut: (hMessage, cb) ->
    #Complete hMessage
    hMessage.publisher = @actor
    if cb
      hMessage.msgid = @h_makeMsgId()
    else
      hMessage.msgid = hMessage.msgid or @h_makeMsgId()
    hMessage.sent = new Date().getTime()

  #
  # Method allowing that creates and start an actor as a child of this actor
  # @param classname {string} the type of the actor to create
  # @param method {string} the method to use to create the actor
  # @param topology {object} the topology of the child actor to create
  # @param cb {function} a function call when the actor is create. It return the child instance as parameters
  # @option cb hChild {object} The instance of the child
  #
  createChild: (classname, method, topology, cb) ->
    unless _.isString(classname) then throw new Error "'classname' parameter must be a string"
    unless _.isString(method) then throw new Error "'method' parameter must be a string"

    childSharedProps = {}
    for prop of topology.sharedProperties
      childSharedProps[prop] = topology.sharedProperties[prop]
    topology.sharedProperties = @sharedProperties
    for prop of childSharedProps
      topology.sharedProperties[prop] = childSharedProps[prop]

    unless topology.trackers then topology.trackers = @trackers
    unless topology.log then topology.log = @log_properties

    # prefixing actor's id automatically
    topology.actor = "#{topology.actor}/#{UUID.generate()}"

    switch method
      when "inproc"
        childRef = factory.newActor classname, topology
        @outboundAdapters.push factory.newAdapter(method, owner: @, targetActorAid: topology.actor, ref: childRef)
        childRef.outboundAdapters.push factory.newAdapter(method, owner: childRef, targetActorAid: @actor, ref: @)
        childRef.parent = @
        # Starting the child
        @send @h_buildSignal(topology.actor, "start", {})

      when "fork"
        childRef = forker.fork __dirname + "/../childlauncher", [classname, JSON.stringify(topology)]
        @outboundAdapters.push factory.newAdapter(method, owner: @, targetActorAid: topology.actor, ref: childRef)
        childRef.on "message", (msg) =>
          if msg.state is 'ready'
            @send @h_buildSignal(topology.actor, "start", {})
      else
        throw new Error "Invalid method"

    if cb
      cb childRef
    # adding aid to referenced children
    @children.push topology.actor

    topology.actor

  #
  # Method called by constructor to initializing logger
  # @private
  # @param logLevel {string} the log level use by the actor
  # @param logFile {string} the file where the log will be write
  #
  h_initLogger: (logLevel, logFile) ->
    logLevels =
      debug: 0,
      info: 1,
      warn: 2,
      error: 3
    @logger = new winston.Logger({levels: logLevels})
    # Don't crash on uncaught exception
    @logger.exitOnError = false

    # Set log display
    @logger.add(winston.transports.Console, {handleExceptions: true, level: logLevel, colorize: true})
    if logFile
      try
        @logger.add(winston.transports.File, {handleExceptions: true, filename: logFile, level: logLevel})
      catch err

  #
  # Method that enrich a message with actor details and logs it to the console
  # @param type {string} the level of the log
  # @param message {object} the log message (with the actor which raise it)
  #
  log: (type, message) ->
    switch type
      when "debug"
        @logger.debug "#{validator.getBareURN(@actor)} | #{message}"
        break
      when "info"
        @logger.info "#{validator.getBareURN(@actor)} | #{message}"
        break
      when "warn"
        @logger.warn "#{validator.getBareURN(@actor)} | #{message}"
        break
      when "error"
        @logger.error "#{validator.getBareURN(@actor)} | #{message}"
        break

  #
  # Method called by constructor to initializing actor's children
  # This method could be override to specified an actor
  # @param children {Array<Object>} Actor's children and their topology
  #
  initChildren: (children)->
    _.forEach children, (childProps) =>
      unless childProps.method
        childProps.method = "inproc"
      @createChild childProps.type, childProps.method, childProps

  #
  # Method called every minuts to inform the tracker about the actor state
  # This method could be override to specified an actor
  # @private
  #
  h_touchTrackers: ->
    _.forEach @trackers, (trackerProps) =>
      if trackerProps.trackerId isnt @actor
        @log "debug", "touching tracker #{trackerProps.trackerId}"
        inboundAdapters = []
        if @status isnt STATUS_STOPPED
          for inbound in @inboundAdapters
            inboundAdapters.push {type: inbound.type, url: inbound.url}

        @send @h_buildSignal(trackerProps.trackerId, "peer-info",
          peerType: @type
          peerId: validator.getBareURN(@actor)
          peerStatus: @status
          peerInbox: inboundAdapters
          peerPID: process.pid
          peerMemory: process.memoryUsage()
          peerUptime: process.uptime()
          peerLoadAvg: os.loadavg()
        )

  #
  # Method called when the actor status change
  # @private
  # @param status {string} New status to apply
  #
  h_setStatus: (status) ->
    unless status is STATUS_READY and Object.keys(@error).length > 0
      # alter the state
      @status = status
      if @timerTouch
        clearInterval(@timerTouch)
      @h_touchTrackers()

      unless status is STATUS_STOPPED
        @timerTouch = setInterval(=>
          @h_touchTrackers()
        , @touchDelay)

      # advertise
      @emit "hStatus", status
      # Log
      @log "debug", "new status:#{status}"

  #
  # Function that starts the actor, including its inbound adapters
  # @private
  #
  h_start: ()->
    @h_setStatus STATUS_STARTING
    @h_initListeners()

    _.invoke @inboundAdapters, "start"
    _.invoke @outboundAdapters, "start"
    @h_setStatus STATUS_STARTED

    for adapterProps in @channelToSubscribe
      @subscribe adapterProps.channel, adapterProps.quickFilter, (status, result) =>
        unless status is codes.hResultStatus.OK
          @log "debug", "Subscription to #{adapterProps.channel} failed cause #{result}"
          errorID = UUID.generate()
          @raiseError(errorID, "Subscription to #{adapterProps.channel} failed")
          @h_autoSubscribe(adapterProps, 500, errorID)

    @initialize () =>
      @h_setStatus STATUS_READY

  #
  # Method to override if you need a specific initialization before considering your actor ready
  # @param done {function}
  #
  initialize: (done) ->
    done()

  #
  # Function that stops the actor, including its children and adapters
  # @private
  #
  h_tearDown: () ->
    @h_setStatus STATUS_STOPPED
    @preStop ( =>
      @h_stop ( =>
        @postStop ( =>
          )))

  #
  # Method to override if you need specifics treatments before stopping the actor.
  # @param done {function}
  #
  preStop: (done) ->
    done()

  #
  # Method called to stop an actor by stopping his children and adapters
  # @private
  # @param done {function}
  #
  h_stop: (done) ->
    # Stop children first
    _.forEach @children, (childAid) =>
      @send @h_buildSignal(childAid, "stop", {})

    # Copy adapters arrays to keep loop safe, as stop method may remove adapters from these arrays
    outboundsTabCopy = []
    inboundsTabCopy = []
    _.forEach @outboundAdapters, (outbound) =>
      outboundsTabCopy.push (outbound)
    _.forEach @inboundAdapters, (inbound) =>
      inboundsTabCopy.push (inbound)
    # Stop adapters
    _.invoke inboundsTabCopy, "stop"
    _.invoke outboundsTabCopy, "stop"
    done()

  #
  # Method to override if you need specifics treatments after stopping the actor.
  # @param done {function}
  #
  postStop: (done) ->
    @removeAllListeners()
    @listenersInited = false
    done()

  #
  # Method called to auto-subscribe to a channel when have channel_in adapter in topology
  # @param adapterProps {object} properties of the channel to subscribe
  # @param delay {int} time to wait before retry to subscribe
  # @param errorID {string} id of the error to close when succesfully subscribe
  #
  h_autoSubscribe: (adapterProps, delay, errorID) ->
    setTimeout(=>
      @subscribe adapterProps.channel, adapterProps.quickFilter, (status2, result2) =>
        unless status2 is codes.hResultStatus.OK
          @log "debug", "Subscription attempt failed cause #{result2}"
          if delay < 60000
            delay *= 2
          else
            delay = 60000
          @h_autoSubscribe(adapterProps, delay, errorID)
        else
          @closeError(errorID)
    , delay)

  #
  # Method called to when a error occur in the actor
  # @param id {string} error id of the error to raise
  # @param message {string} error's message which describe the error
  #
  raiseError: (id, message) ->
    @h_setStatus STATUS_ERROR
    @error[id] = message

  #
  # Method called to when a error can be close
  # @param id {string} error id of the error to close
  #
  closeError: (id) ->
    delete @error[id]
    if Object.keys(@error).length is 0
      @h_setStatus STATUS_READY


  #
  # Method called to set a filter on the actor
  # This method could be override to specified an actor
  # @param hCondition {object} The filter to set
  # @param cb {function} the callback to call after setting the filter
  # @option cb status {integer} The status code of the method (0 if no_error)
  # @option cb result {string} A message which describe the result (empty if no_error)
  #
  setFilter: (hCondition, cb) ->
    if not hCondition or (hCondition not instanceof Object)
      return cb codes.hResultStatus.INVALID_ATTR, "invalid filter"

    checkFormat = hFilter.checkFilterFormat(hCondition)

    if checkFormat.result is true
      @filter = hCondition
      cb codes.hResultStatus.OK, ""
    else
      cb codes.hResultStatus.INVALID_ATTR, checkFormat.error

  #
  # Method called on incoming message to check if the hMessage respect the actor's filter
  # This method could be override to specified an actor
  # @param hMessage {object} hMessage to check with the actor's filter
  #
  validateFilter: (hMessage) ->
    return hFilter.checkFilterValidity(hMessage, @filter, {actor:@actor})

  #
  # Method called to subscribe to a channel
  # If a quickFilter is specified, the method subscribe the actor just for this quickFilter
  # @param hChannel {string} URN of the channel to subscribe
  # @param quickFilter {string} quickFilter to apply on the channel
  # @param cb {function} callback called when the susbscibe is done
  # @option cb status {integer} The status code of the method (0 if no_error)
  # @option cb result {string} A message which describe the result (empty if no_error)
  #
  subscribe: (hChannel, quickFilter, cb) ->
    status = undefined
    result = undefined
    if typeof quickFilter is "function"
      cb = quickFilter
      quickFilter = ""
    if quickFilter is undefined or quickFilter is null
      quickFilter = ""

    for channel in @subscriptions
      if validator.getBareURN(channel) is hChannel
        _.forEach @inboundAdapters, (inbound) =>
          if inbound.channel is hChannel
            findfilter = false
            findglobalfilter = false
            for qckFilter in inbound.listQuickFilter
              if qckFilter is quickFilter
                findfilter = true
              if qckFilter is ""
                findglobalfilter = true
            if findfilter is false
              inbound.addFilter(quickFilter)
              if findglobalfilter
                inbound.removeFilter "", ()->
              status = codes.hResultStatus.OK
              result = "QuickFilter added"
              return
        if status isnt undefined
          return cb status, result
        else
          return cb codes.hResultStatus.NOT_AUTHORIZED, "already subscribed to channel " + hChannel

    @send @buildCommand(hChannel, "hSubscribe", {}, {timeout: 3000}), (hResult) =>
      if hResult.payload.status is codes.hResultStatus.OK and hResult.payload.result
        channelInbound = factory.newAdapter("channel_in", {url: hResult.payload.result, owner: @, channel: hChannel, filter: quickFilter})
        @inboundAdapters.push channelInbound
        channelInbound.start()
        @subscriptions.push hResult.publisher
        if cb
          cb codes.hResultStatus.OK
      else
        cb hResult.payload.status, hResult.payload.result

  #
  # Method called to unsubscribe to a channel.
  # If a quickFilter is specified, the method unsubscribe the actor just for this quickFilter
  # Else the actor is unsubsribe of all the channel
  # @param hChannel {string} URN of the channel to unsubscribe
  # @param quickFilter {string} quickFilter to removed from the channel
  # @param cb {function} callback called when the unsusbscibe is done
  # @option cb status {integer} The status code of the method (0 if no_error)
  # @option cb result {string} A message which describe the result (empty if no_error)
  #
  unsubscribe: (hChannel, quickFilter, cb) ->
    if typeof quickFilter is "function"
      cb = quickFilter
      quickFilter = undefined

    unless hChannel
      return cb codes.hResultStatus.MISSING_ATTR, "Missing channel"

    index = 0
    subs = false
    for channel in @subscriptions
      if validator.getBareURN(channel) is hChannel
        subs = true
        if quickFilter is undefined
          @subscriptions.splice(index, 1)
      index++

    if subs is false
      return cb codes.hResultStatus.NOT_AVAILABLE, "user not subscribed to " + hChannel
    else
      index = 0
      _.forEach @inboundAdapters, (inbound) =>
        if inbound.channel is validator.getBareURN(hChannel)
          if inbound.started
            if quickFilter
              inbound.removeFilter quickFilter, (result) =>
                if result
                  @unsubscribe hChannel, cb
                else
                  return cb codes.hResultStatus.OK, "QuickFilter removed"
            else
              inbound.stop()
              @inboundAdapters.splice(index, 1)
              index2 = 0
              for channel in @subscriptions
                if channel is hChannel
                  @subscriptions.splice(index2, 1)
                index2++
              return cb codes.hResultStatus.OK, "Unsubscribe from channel"
        index++

  #
  # Method called to get the actor subscriptions
  # @return {Array}
  #
  getSubscriptions: () ->
    return @subscriptions

  #
  # Method called to update adapter
  # @param name {string} name of the adapter to update
  # @param properties {object} new properties to apply
  #
  updateAdapter: (name, properties) ->
    adapter = _.find @inboundAdapters, (inbound) =>
      if inbound.properties and inbound.properties.name
        inbound.properties.name is name
    if adapter
      adapter.update(properties)
    else
      @log "error", "Can't find adapter #{name} for update"

  #
  # Method called to remove a actor from outboundAdapter
  # @param actor  {string} URN of the actor to remove
  #
  removePeer: (actor) ->
    @log "debug", "Removing peer #{actor}"
    index = 0
    _.forEach @outboundAdapters, (outbound) =>
      if outbound.targetActorAid is actor
        outbound.stop()
        @outboundAdapters.splice(index, 1)
        if @trackers[0]
          @unsubscribe @trackers[0].trackerChannel, actor, () ->

      index++

  #
  # Method called to build correct hMessage
  # @param actor {string} URN of the target of the hMessage
  # @param type {string} Type of the hMessage
  # @param payload {object} Content of the hMessage
  # @param options {object} Optionals attributs of the hMessage
  #
  buildMessage: (actor, type, payload, options) ->
    options = options or {}
    hMessage = {}
    unless actor
      throw new Error("missing actor")
    hMessage.publisher = @actor
    hMessage.msgid = UUID.generate()
    hMessage.published = hMessage.published or new Date().getTime()
    hMessage.actor = actor
    hMessage.ref = options.ref  if options.ref
    hMessage.convid = options.convid  if options.convid
    hMessage.type = type  if type
    hMessage.priority = options.priority  if options.priority
    hMessage.relevance = options.relevance  if options.relevance
    if options.relevanceOffset
      currentDate = new Date().getTime()
      hMessage.relevance = new Date(currentDate + options.relevanceOffset).getTime()
    if options.persistent isnt null or options.persistent isnt undefined
      hMessage.persistent = options.persistent
    if hMessage.persistent is null or hMessage.persistent is undefined
      hMessage.persistent = false
    hMessage.location = options.location  if options.location
    hMessage.author = options.author  if options.author
    hMessage.published = options.published  if options.published
    hMessage.headers = options.headers  if options.headers
    hMessage.payload = payload  if payload
    hMessage.timeout = options.timeout  if options.timeout
    hMessage

  #
  # Method called to build correct hSignal
  # @private
  # @param actor {string} URN of the target of the hMessage
  # @param name {string} The name of the hSignal
  # @param params {object} The parameters of the hSignal
  # @param options {object} Optionals attributs of the hMessage
  #
  h_buildSignal: (actor, name, params, options) ->
    params = params or {}
    options = options or {}
    options.persistent = options.persistent or false
    throw new Error("missing cmd")  unless name
    hSignal =
      name: name
      params: params

    @buildMessage actor, "hSignal", hSignal, options

  #
  # Method called to build correct hCommand
  # @param actor {string} URN of the target of the hMessage
  # @param cmd {string} Type of the hCommand
  # @param params {object} The parameters of the hCommand
  # @param options {object} Optionals attributs of the hMessage
  #
  buildCommand: (actor, cmd, params, options) ->
    params = params or {}
    options = options or {}
    throw new Error("missing cmd")  unless cmd
    hCommand =
      cmd: cmd
      params: params

    @buildMessage actor, "hCommand", hCommand, options

  #
  # Method called to build correct hResult
  # @param actor {string} URN of the target of the hMessage
  # @param ref {string} The msgid of the message refered to
  # @param status {number} The status of the operation
  # @param result {object, array, string, number, boolean} The result of a command operation
  # @param options {object} Optionals attributs of the hMessage
  #
  buildResult: (actor, ref, status, result, options) ->
    options = options or {}
    throw new Error("missing status")  if status is `undefined` or status is null
    throw new Error("missing ref")  unless ref
    hResult =
      status: status
      result: result

    options.ref = ref
    @buildMessage actor, "hResult", hResult, options

  #
  # Method called to build correct hMeasure
  # @param actor {string} URN of the target of the hMessage
  # @param value {number} The value of the hMeasure
  # @param unit {string} The unit in which the measure is expressed
  # @param options {object} Optionals attributs of the hMessage
  #
  buildMeasure: (actor, value, unit, options) ->
    unless value
      throw new Error("missing value")
    else throw new Error("missing unit")  unless unit
    @buildMessage actor, "hMeasure", {unit: unit, value: value}, options

  #
  # Method called to build correct hAlert
  # @param actor {string} URN of the target of the hMessage
  # @param alert {string} The message provided by the author to describe the alert
  # @param options {object} Optionals attributs of the hMessage
  #
  buildAlert: (actor, alert, options) ->
    throw new Error("missing alert")  unless alert
    @buildMessage actor, "hAlert", {alert: alert}, options

  #
  # Method called to build correct hAck
  # @param actor {string} URN of the target of the hMessage
  # @param ref {string} The message provided by the author to describe the alert
  # @param ack {string} The status of the acknowledgement
  # @param options {object} Optionals attributs of the hMessage
  #
  buildAck: (actor, ref, ack, options) ->
    throw new Error("missing ack")  unless ack
    unless ref
      throw new Error("missing ref")
    else throw new Error("ack does not match \"recv\" or \"read\"")  unless /recv|read/i.test(ack)
    options = {}  if typeof options isnt "object"
    options.ref = ref
    @buildMessage actor, "hAck", {ack: ack}, options

  #
  # Method called to build correct hConvState
  # @param actor {string} URN of the target of the hMessage
  # @param convid {string} Convid of the thread describe by the status
  # @param status {string} The status of the thread
  # @param options {object} Optionals attributs of the hMessage
  #
  buildConvState: (actor, convid, status, options) ->
    unless convid
      throw new Error("missing convid")
    else throw new Error("missing status")  unless status
    options = {}  unless options
    options.convid = convid
    @buildMessage actor, "hConvState", {status: status}, options

  #
  # Create a unique message id
  # @private
  #
  h_makeMsgId: () ->
    msgId = UUID.generate()
    msgId

  #
  # Called by an adapter that wants to register as a "watcher" for a peer
  # @private
  # @param actor {string} URN of the peer watched
  # @param refAdapter {object} Adapter that wants to watch a peer
  # @param cb {function} Function to call when unwatching
  #
  h_watchPeer: (actor, refAdapter, cb) ->
    if @watchingsTab.length is 0 and @trackers[0]
      @subscribe @trackers[0].trackerChannel, actor, () ->
    watching =
      actor: actor,
      adapter: refAdapter,
      cb: cb
    @watchingsTab.push(watching)

  #
  # Called by an adapter that wants to unregister as a "watcher" for a peer
  # @private
  # @param actor {string} URN of the peer watched
  # @param refAdapter {object} Adapter that wants to unwatch a peer
  #
  h_unwatchPeer: (actor, refAdapter) ->
    nbWatchActor = 0
    index = 0
    for watching in @watchingsTab
      if validator.getBareURN(watching.actor) is validator.getBareURN(actor)
        if watching.adapter is refAdapter
          cb = watching.cb
          cb.call(watching.adapter)
          indexToRemove = index
        else
          nbWatchActor++
      index++

    @watchingsTab.splice(indexToRemove, 1)
    if nbWatchActor is 0
      @removePeer(actor)

  #
  # Called by an adapter that wants to be removed from actor's adapters lists
  # @private
  # @param refAdapter {object} Adapter to be removed
  #
  h_removeAdapter: (refadapter) ->
    unless refadapter is undefined
      index = -1
      outboundAdapterToRemove = _.find @outboundAdapters, (outbound) =>
        index++
        outbound is refadapter
      if outboundAdapterToRemove isnt undefined
        outboundAdapterToRemove.stop()
        @outboundAdapters.splice(index, 1)
      index = -1
      inboundAdapterToRemove = _.find @inboundAdapters, (inbound) =>
        index++
        inbound is refadapter
      if inboundAdapterToRemove isnt undefined
        inboundAdapterToRemove.stop()
        @inboundAdapters.splice(index, 1)




UUID = ->
UUID.generate = ->
  a = UUID._gri
  b = UUID._ha
  b(a(32), 8) + "-" + b(a(16), 4) + "-" + b(16384 | a(12), 4) + "-" + b(32768 | a(14), 4) + "-" + b(a(48), 12)

UUID._gri = (a) ->
  (if 0 > a then NaN else (if 30 >= a then 0 | Math.random() * (1 << a) else (if 53 >= a then (0 | 1073741824 * Math.random()) + 1073741824 * (0 | Math.random() * (1 << a - 30)) else NaN)))

UUID._ha = (a, b) ->
  c = a.toString(16)
  d = b - c.length
  e = "0"

  while 0 < d
    d & 1 and (c = e + c)
    d >>>= 1
    e += e
  c


module.exports = Actor
