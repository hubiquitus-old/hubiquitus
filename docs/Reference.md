# Hubiquitus: the reference

> IMPORTANT NOTICE: this document in under active writing

This document describes the internals of the Hubiquitus framework.

## Introduction

### The question

The post-PC era has come, marked by the emergence of plenty of digital devices - e-readers, smartphones, tablets, TVs, home weather stations, watches, snowboard goggles, tennis rackets, running shoes, boilers, supply meters, and so on - each of them especially adapted to a specific range of use cases and contexts.

More than screens, such devices now ship with an ever growing list of sensors - accelerometers, gyrometers, compass, microphones, cameras, GPS - that permanently observe their immediate proximity, thus enriching the global context data - time, social network posts, open data updates - with local live measures.

Taking advantage of this new digital space involves new requirements regarding the way we build apps:

* **ubiquity**: we need to deploy our apps to any kind of device, operating system or platform.
* **awareness**: we need to be able to collect any kind of context data - should it come from local sensors, social networks, open data APIs or any other API providing live context data - and send it to any application that could need it.
* **immediacy**: context moves quickly so its state should be streamed and processed as fast as possible.
* **persistence**: we should be able to store the context data so that it could be further queried, processed or even replayed.

### The hubiquitus answer

Hubiquitus aims to provide a simple way to develop apps that fulfill with these requirements. It is basically an ubiquitous programming model for building context-aware distributed live apps as networks of *smart agents*, deployed to various platforms and devices, that use messages to communicate with each other in near real-time.

![agents network](https://github.com/hubiquitus/hubiquitus/raw/master/docs/images/AgentsNetwork.jpg)

The Hubiquitus framework provides the following features:

* **actor-based apps**: the *smart agents* developed using Hubiquitus are basically made of actors, a lightweight form of concurrent computational entities that sequentially process messages from an event-driven receive loop called a Reactor. Each actor makes its own decisions regarding what to do with incoming messages.
* **message-driven communication**: like humans, Hubiquitus actors are autonomous entities which state is not shared nor synchronized with other actors state. This "share nothing" strategy is enforced by using an asynchronous message-driven communication between actors. Hubiquitus actors can exchange messages through either a point-to-point, a request-reply, a publish-subscribe, a master-worker strategy or a combination of these patterns. Hubiquitus also provides a dynamic content-based message filtering system.
* **p2p connections**: Hubiquitus adopts a broker-less P2P distribution model in which actors discover and connect each other dynamically at runtime, thus allowing to implement easily resilient and elastic architectures. Peering also provides more direct connections which contribute to reduce communication latency.
* **fast & lightweight transport**: actors connect each other using various forms of sockets used to transport messages using a very small footprint transport protocol  ; the combination of PGM, TCP and HTML5 Web sockets allows covering most network topologies.
* **historical data**: the whole messaging history can be transparently logged into various persistent stores.
* **JavaScript SDK**: the dynamic scripting language of the web may not be the perfect language we all dream about, but it is undoubtedly the most ubiquitous one. It allows developers to code apps that are able to reach practically any device running a JavaScript engine.
* **bridges to the outside world**: even JavaScript can't run on every platforms, so Hubiquitus provides native bindings for major platforms such as iOS, Android and Windows 8. Hubiquitus also provides a wide range of network adapters allowing to integrate your apps with social networks (Twitter, Google+, …), push notification services (APNS, GCM, …)

## The actors engine

### Hubiquitus actors

The *smart agents* of Hubiquitus are made of *actors*, as the [Actor Model](http://en.wikipedia.org/wiki/Actor_model) paradigm defines them:

> **An actor is a form of lightweight computational entity that process sequentially incoming messages it receives**

The fundamental properties of an actor are:

* each actor has an **inbox**, a kind of FIFO queue into which other actors and programs can post messages to be processed,
* each actor implements its own **behavior**, a function that is triggered each time a message is posted into its inbox,
* each actor maintains its own **state** that it doesn't share with anyone else ("share nothing" principle); this state can be modified as the actor processes incoming messages.
* each actor can itself send **messages** to other actors; posting message is asynchronous so that it never blocks the process in which the actor is running,
* each actor can create **children** to which it will then be able to post messages as to any other actor.

The following figure summarizes these principles:

![actor model](https://github.com/hubiquitus/hubiquitus/raw/master/docs/images/ActorModel.png)

#### *Runtime environment*

Hubiquitus implements the technical contrat as a JavaScript prototype for the [NodeJS](http://nodejs.org) evented programming platform (to be more precise, Hubiquitus is coded in CoffeeScript, a compact language that produces JavaScript code).

NodeJS is a great choice as a runtime environment for actors since it provides features that comply with many aspects of the actor model:

* **Performances**: NodeJS relies on the V8 JavaScript engine, which means that the JavaScript code is compiled on-the-fly into machine code  
* **Single threaded execution**: each NodeJS process run JavaScript programs using a single execution thread, so we are sure to never have to deal with concurrency issues
* **Evented asynchronous I/O**: NodeJS allows binding *functions* to specific I/O events - such as "bytes have been written to this socket", thus providing out-of-the-box an elegant implementation of the inbox/thread of control/behaviour logic. The asynchronous nature of NodeJS also allows making multiple actors running in a single process. 
* **Child processes**: NodeJS natively supports creating forked process that communicates with their parent process using sockets, so that creating child actors as child processes becomes trivial.

#### *Lifecycle*

Hubiquitus actors lifecycle pass through 4 possible running states:

* **STARTING**: the actor has been created is about to start, but it is unable to process ingoing messages yet
* **STARTED**: the actor has started and enters into an initialization phase, but it is unable to process ingoing messages yet
* **READY**: the actor is ready to receive and process ingoing messages
* **ERROR**: the actor falled into a corrupted state so that it is unable to receive and process ingoing messages 
* **STOPPING**: the actor is about to stop and will not process ingoing messages anymore

> TODO : insert state diagram

#### *Identity*

Each actor has an **identity** (ID), a name that identifies each actor inside an actors network.

Developers are expected to assign to each actor (i.e. instance) an ID so that Hubiquitus can properly route messages adressed to it.

As an example, the following string is a valid actor's ID :
 
```
	urn:hubiquitus.org:johndoe
```

Each time Hubiquitus starts an actors, Hubiquitus will generate and appends to its ID a brand new Universal Unique Identifier (UUID) so that the unicity of each ID is always guaranteed by the framework.

As an example, the following string is a valid actor's runtime ID :
 
```
	urn:hubiquitus.org:johndoe/110E8400-E29B-11D4-A716-446655440000
```

#### *SDK*

Hubiquitus implements the technical contract for all actors, letting developers code the custom behavior of their own actors.

**Hubiquitus expects developers to provide a single JavaScript function that implements that behaviour.**

Hubiquitus provides a set of JavaScript APIs that developers can use while implementing the behaviour function.

The actors SDK provides the following functions:

* **send**: this function allows to send a message to a recipient
* **createChild**: this function allows an actor to create another actor as one of its children

> TODO describe what an actor can do

### Messages

Actors communicate in an asynchronous manner using **messages**.

A message can be seen as an atomic piece of transferable data composed of two distinct parts:

* a **payload**: a piece of data that is the fundamental purpose of the transmission
* an **enveloppe**: a piece of related metadata providing information necessary to the proper delivery of the message 

Hubiquitus defines a **standard data structure** for messages so that they can be properly delivered to their recipients and be processed by them.

### Adapters

**Adapters are special Hubiquitus components that provide messaging features to actors**

Adapters provides the following features:

* **message transfer** : adapters provide wire-level protocols to transfer the messages over the IP network.
* **message serialization** : adapters carry out the serialization of the messages so that they can be transfered over the network
* **message encryption** : adapters guarantee the confidentiality of the communications by using wire-level encryption
* **emitters authentication** : adapters provide transport-level authentication so that actors can trust the authenticity of the messages they receive
* **message filtering** : adapters allow filtering ingoing and outgoing messages that match a given pattern
* **authorization** : adapters allow protecting actors from receiving messages from unauthorized emitters

Hubiquitus allows using **multiple combinations of serialization formats and wire-level protocols**. You can use the best one to transport a message, depending on its format (do I need a carry out binary messages ?) and the availability of the transport itself (can I use WebSocket here ?).

> TODO insert a diagram explaining the message flow

#### *Inbound and outbound adapters*

Hubiquitus provides two distinct classes of adapters, each of them being complementary to the other like the faces of a coin:

* **inbound adapters**, kind of *sockets* required to listen to ingoing messages from the outside world, including actors
* **outbound adapters**, kind of *plugs* required to send outgoing messages to the outside world, including actors

The figure below explains how inbound and outbound adapters work together to enable a communication link between a *sender* and a *recipient*:
![adapters](https://github.com/hubiquitus/hubiquitus/raw/master/docs/images/Adapters.png)

#### *Adapters scopes*

Inbound and outbound adapters fall into three *scope categories*:

*   **INPROC adapters** refer to adapters enabling a messaging link between actors that reside into the same process
*   **IPC adapters** refer to adapters enabling a messaging link between actors that reside on the same network host but in distinct running process
*   **REMOTE adapters**: refer to adapters enabling a messaging link between actors that reside on distinct network hosts

The figure below explains this mechanism: 
> TODO : INSERT DIAGRAM

#### *Built-in adapters*

Hubiquitus provides out-of-the-box multiple pairs of adapters, each of them implementing a specific wire-level transport protocol.

<table>
    <thead>
        <tr>
            <th>Inbound adapter</th>
            <th>Outbound adapter</th>
            <th>Scope</th>
            <th>Protocol</th>
            <th>Since</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>LocalIA</td>
            <td>LocalOA</td>
            <td>INPROC</td>
            <td>in-memory message copy</td>
            <td>Hubiquitus v0.6</td>
        </tr>
        <tr>
            <td>TimerAdapter</td>
            <td>(in only)</td>
            <td>INPROC</td>
            <td>in-memory message copy</td>
            <td>Hubiquitus v0.6</td>
        </tr>
        <tr>
            <td>LocalSocketIA</td>
            <td>LocalSocketOA</td>
            <td>INPROC</td>
            <td>ØMQ inproc transport</td>
            <td>Hubiquitus v0.7</td>
        </tr>
        <tr>
            <td>IpcSocketIA</td>
            <td>IpcSocketOA</td>
            <td>IPC</td>
            <td>ØMQ IPC transport</td>
            <td>Hubiquitus v0.7</td>
        </tr>
        <tr>
            <td>TcpSocketIA</td>
            <td>TcpSocketOA</td>
            <td>REMOTE</td>
            <td>ØMQ TCP transport</td>
            <td>Hubiquitus v0.6</td>
        </tr>
        <tr>
            <td>HttpIA</td>
            <td>HttpOA</td>
            <td>REMOTE</td>
            <td>NodeJS HTTP transport</td>
            <td>Hubiquitus v0.6</td>
        </tr>
        <tr>
            <td>SioIA</td>
            <td>SioOA</td>
            <td>REMOTE</td>
            <td>Socket IO WebSocket/XHR-based transport</td>
            <td>Hubiquitus v0.6</td>
        </tr>
        <tr>
            <td>TwitterAdapter</td>
            <td>TwitterAdapter</td>
            <td>REMOTE</td>
            <td>Twitter's real-time HTTP-based transport</td>
            <td>Hubiquitus v0.6</td>
        </tr>
    </tbody>
</table>

We expect additional adapters to be included in future releases:

* MQTT
* Google plus
* Facebook
* Instagram

> NOTE : place "special" adapters (ex: Channel, Twitter, Timer, etc.) in "special" sections

#### *Message serialization*

Hubiquitus provides multiple message encoders, each one being compatible with some of the adapters Hubiquitus provides.

Here is the list of serializers that Hubiquitus provides.

Since v0.6:

* `JsonSerializer`: default format / compatible with all transports / shipped with Hubiquitus v0.6

In future releases:

* `MsgPackSerializer`: uses the MessagePack format / incompatible with SocketIO

> TO BE DESCRIBED

#### *Message filtering*

> TO BE DESCRIBED

#### *Authenticators*

> TO BE DESCRIBED

## Built-in actors

Hubiquitus provide a set of built-in actors providing special features:

* **Channel**: actor providing publish-subscribe messaging features
* **Gateway**: actor providing a messaging gateway between actors
* **Session**: actor providing as a mirror of another actor placed behind a gateway

> TODO : add any another actors

### Channel

**Channels are built-in Hubiquitus actors that implement the Publish-Subscribe pattern**.

Publish–Subscribe is a messaging pattern where senders of messages, called publishers, do not program the messages to be sent directly to specific receivers, called subscribers. Instead, published messages are characterized into classes, without knowledge of what, if any, subscribers there may be. Similarly, subscribers express interest in one or more classes, and only receive messages that are of interest, without knowledge of what, if any, publishers there are.

Channels implement those *classes* as shown in the diagram below:
![channels](https://github.com/hubiquitus/hubiquitus/raw/master/docs/images/Channels.png)

Channels come with a set of related adapters:

* ChannelAdapter: a dedicated adapter mixing inbound and outbound adapters caracteristics in a single adapter objet
* ChannelOutboundAdapter: an outbound adapter that actors can use to *publish* messages to a channel ; connects to the ChannelAdapter of the targeted channel
* ChannelInboundAdapter: an inbound adapter that actors can use to *subscribe* to a channel so that they will receive a copy of every message posted to a channel ; connects to the ChannelAdapter of the targeted channel

> TODO : links to the code

### Gateway

> TO BE DESCRIBED

## Session

> TO BE DESCRIBED

## Programming actors

### Step 1: implement a *function*

The Actor class (and its dependencies) implement the whole technical contract of an actor, so that **the developer only has to provide the behaviour**.

Since functions are first-class citizens in JavaScript, the behaviour is very simple to implement: **its a simple function**.

As an example, the following function is a valid behaviour:

``` js
	// A sample behaviour function
	function logAny(message) {
    	console.log "myActor receive a hMessage", hMessage
    }
```

### Step 2: write an actors *topology*

Hubiquitus needs to know a little bit more about your actors so that it can make them run properly : you have to **describe it**.

The most simple way to describe an actor is to **provide a topology file**, a simple JSON file that describes the actors to run. 

Please notice that you can declare as many actors as you want into a single topology file.

#### First give a name to your actor

Each actor MUST be named with an identifier that MUST remain unique accross a topology file:

IDs of Hubiquitus actors comply with the [**Uniform Resource Name**](http://tools.ietf.org/html/rfc2141) IETF standard.

The example below presents a minimal actor's topology.

``` js
{
	"id": "urn:example.com:barrack"
}
```

#### Type

Actors MAY have a `type`.

Hubiquitus uses a default prototype for actors, but it is not really useful for real cases. Most actors, if not all of them, will declare a specific type:

* The type MUST belong to the list of prototypes deployed in Hubiquitus.

The example below present the topology of a typed actor:
```js
{
    "id": "urn:example.com:barrack",
    "type": "president"
}
```

> TODO : EXPLAIN HOW TO PASS THE BEHAVIOR FUNCTION AND LINK IT TO THE TYPE

#### Adapters

> TODO

### Topology of actors

The caracteritics of each actor are described using a set of mandatory and optional properties that the Hubiquitus framework needs to be aware of in order to make it run properly.

Each actor stores these properties in a JavaScript object that we call a **topology**.

The examples below use a JSON representation of this object to make them better understandable to the reader of this guide.

#### ID

Actors MUST have an `ID`.

Actors IDs MUST comply with the following constraints:

* Their format comply with the [**Uniform Resource Name**](http://tools.ietf.org/html/rfc2141) IETF standard. For example, the following string is a valid name for a hActor: `urn:hubiquitus.org:johndoe`.
* They MUST be unique accross a cluster of connected actors.

The example below presents a minimal actor's topology.
```js
{
    "id": "urn:example.com:barrack"
}
```

#### Type

Actors MAY have a `type`.

Hubiquitus uses a default prototype for actors, but it is not really useful for real cases. Most actors, if not all of them, will declare a specific type:

* The type MUST belong to the list of prototypes deployed in Hubiquitus.

The example below present the topology of a typed actor:
```js
{
    "id": "urn:example.com:barrack",
    "type": "president"
}
```

#### Adapters

> TODO

#### References explicitely resolve remote actors

> TODO

#### Children

> TODO