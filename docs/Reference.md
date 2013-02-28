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

### Our answer

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

## Hubiquitus concepts

### Actors

The *smart agents* of Hubiquitus are made of *actors*, as the [Actor Model](http://en.wikipedia.org/wiki/Actor_model) paradigm defines them:

> **An actor is a form of lightweight computational entity that process sequentially incoming messages it receives**

The fundamental properties of an actor are:

* each actor has an **inbox**, a kind of FIFO queue into which other actors and programs can post messages to be processed,
* each actor implements its own **behavior**, a function that is triggered sequentially for each message received in its inbox,
* each actor maintains its own **state** that it doesn't share with anyone else ("share nothing" principle); this state can be modified as the actor processes incoming messages.
* each actor can itself send **messages** to other actors; posting message is asynchronous so that it never blocks the process in which the actor is running,
* each actor can create **children** to which it will then be able to post messages as to any other actor.

The following figure summarizes these principles:

![actor model](https://github.com/hubiquitus/hubiquitus/raw/master/docs/images/ActorModel.png)

### Adapters

**Adapters** are special Hubiquitus components that provide messaging features to actors :

* actors need **inbound adapters** to listen to ingoing messages from the outside world
* actors need **outbound adapters** to send outgoing messages to the outside world

The figure below explains this principle:
![adapters](https://github.com/hubiquitus/hubiquitus/raw/master/docs/images/Adapters.png)

### Channels

> TO BE DESCRIBED

## Framework overview

The Hubiquitus framework is made of a set of complementary building blocks:

* an actor-based **applications container**
* a rich set of **messaging protocols**
* a powerful **messaging middleware**

## Container

First of all, Hubiquitus is an application container.

### Technical design

#### A NodeJS-based lighweight container

The Hubiquitus container is basically a lightweight container for actors. It is highly inspired by existing actor-based frameworks, such as [Erlang OTP](http://www.erlang.org/) or [Akka](http://akka.io), and other lightweight containers such as the [Spring Framework](http://www.springsource.org/spring-framework).

The Hubiquitus actors engine is built on top of the [NodeJS](http://nodejs.org) evented programming platform.

NodeJS is a great choice as a container for actors since it provides features that comply with many aspects of the actor model:

* **Asynchronous I/O**: NodeJS allows binding *functions* to specific I/O events - such as "bytes has been written to this socket" - without blocking the execution thread until it occurs. This provides a simple and elegant way to implement the mechanism of the actor's inbox.
* **Single threaded execution**: each NodeJS process run programs using a single execution thread, we are sure to never have to deal with concurrency issues.
* **Child processes**: NodeJS natively supports creating forked process that communicates with their parent process using sockets, so that creating child actors as child processes becomes trivial.


## Protocols

Actors need to receive, process and send *messages* to each other. Hubiquitus specifies a set of protocols that define the contract that those messages must comply with:

* the **Hubiquitus core messaging protocol** defines the common message structures that every actor must use when it comes to send messages
* the **Hubiquitus pub/sub protocol** defines the way actors can exchange messages through a pub/sub messaging style
* the **Hubiquitus naming protocol** defines a set of messages that actors use to discover the physical location of the other actors

> * **fire and forget messaging** : an actor should be able to send a message to another actor without worrying if the message has been received or not
* **request-response messaging**: an actor should be able to request another actor for specific data using messages
* **pub/sub messaging**: actors should be able to broadcast messages to any recipient that manifest its interest in receiving such ones on a subscription basis

### The Hubiquitus core messaging protocol

> to be described

We designed the hubiquitus messaging protocol with the following constraints in mind:

* **standard structure** : every message payloads should be encapsulated into a common structure responsible for carrying the metatada that the middleware need to properly route and transport the messages through the network
* **extensible structure** : the message structure  should though be able to carry any kind of data and metadata, allowing developers to design specialized protocols depending on their needs (a philosophy of design it shares with XMPP, SOAP and other XML-based protocols)

### The Hubiquitus pub/sub protocol

> TO BE DESCRIBED

#### Channels

> TO BE DESCRIBED

### The Hubiquitus tracking protocol

> TO BE DESCRIBED

* **dynamic addressing and discovery**: actors should not need to know the location of each other to exchange messages

#### Trackers

In order to allow a dynamic topology of actors accross hosts and network, each actor only knowns the *names* of the other actors it needs to talk with: it doesn't know their *addresses*.

To enable them to communicate, Hubiquitus dynamically wire their inboxes through a kind of *directory service* to which  each actor registers so that the address of its inbox can be resolved on demand at runtime. 

This service take the form of a particular kind of actor called a ***tracker***. Each time an actor registers or unregisters to a tracker, this tracker will update its dictionary of peers.

Like any other actor, a tracker can register itself to other trackers so that an address can be resolved accross multiple trackers. This mechanism allows federating multiple groups of actors together.

> TO COME HERE: schema of the principles explained above ; links to the code

## Middleware

The set of protocols we specified before must be implemented by a middleware. The Hubiquitus framework also provides that middleware.

> **The Hubiquitus middleware follows a decentralized and brokerless design**.

### Features

#### Transport

The main purpose of a middleware is to transport data between emitters and recipients. 

The Hubiquitus middleware thus provides the following key features:

* **message encoding** : the middleware carries out the encoding and the decoding of the messages so that they can be transfered over the network.
* **network transfer** : the middleware provides wire-level protocols to transfer the messages over the IP network.

Hubiquitus allows using **multiple combinations of encoding formats and network protocols**. You can use the best one to transport a message, depending on its format (do I need a carry out binary messages ?) and the availability of the transport itself (can I use WebSocket here ?).

#### Security

The hubiquitus middleware also provides advanced security features:

* **authentication** : each message emitter can be properly authenticated by the middleware so actors can trust the messages they receive
* **authorization** : the middleware should allow protecting actors from receiving messages from unauthorized emitters
* **encryption** : the middleware should guarantee the confidentiality of the communications by using wire-level encryption
* **pattern-matching** : the middleware allows filtering ingoing and outgoing messages that match a given pattern

### Adapters

**The Hubiquitus middleware features are implemented by a family of components we call 'adapters'**.

You'll always need at least two adapters to enable a messaging communication link:

* an adapter is used by the message emitter to send the message over the network
* another adapter is used by the message receiver to received the message from the network

The following figure explains this principle:
![adapters](https://github.com/hubiquitus/hubiquitus/raw/master/docs/images/Adapters.png)

#### Flow processing pipeline

Adapters process the message flow as a sequence of processing steps, some of them being optional, as shown below:
> TODO

* guarantying that every message received by or sent to actors comply with the `hMessage` format (the common enveloppe)
* eventually translating the messages written in other formats into a compliant `hMessage`  
* carrying the messages through the network using multiple combinations of wire-level protocols and encoders
* ensuring the confidentiality of the communications through transport-layer security mechanisms
* guarantying the authenticity of the each message through proper authentication of each sender

#### Provided transports

Here is the list of `adapters` that Hubiquitus provides.

Since `v0.6`:

* `In memory`: default transport / useful to send direct messages to actors that run in the same process
* `SocketInboundAdapter`: triggers the actor's behavior each time a message is received on a binded ZeroMQ PULL socket
* `SocketOutboundAdapter`: uses a 0MQ PUSH socket to send messages to a target actor
* `ChannelInboundAdapter`: uses a 0MQ SUB socket to suscribe and receive messages published through a `channel`
* `ChannelOutboundAdapter`: used by `channels` to broadcast messages published through them to their subscribers ; uses a 0MQ PUB socket to publish data to subscribers 
* `SocketIOAdapter`: uses the `SocketIO` library to make actors exchange messages with remote clients on the Internet
* `TwitterAdapter`: used to make actors able to receive and send tweets

In future releases:

* MQTT
* Google plus
* Facebook
* Instagram

#### Provided encoders

Hubiquitus provides multiple message encoders, each one being compatible with some of the adapters Hubiquitus provides.

Here is the list of serializers that Hubiquitus provides.

Since v0.6:

* `JsonSerializer`: default format / compatible with all transports / shipped with Hubiquitus v0.6

In future releases:

* `MsgPackSerializer`: uses the MessagePack format / incompatible with SocketIO

> TO BE COMPLETED

#### Authenticators

> TO BE DESCRIBED

#### Filters

> TO BE DESCRIBED

### How it works ?

> TO BE DESCRIBED

#### The actor's lifecycle

The 6 actors running states:

* STARTING
* STARTED
* PAUSING
* PAUSED
* STOPPING
* STOPPED

> TODO : insert state diagram and explanations ; explain the interceptors

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

#### Behaviour

Choosing NodeJS means using JavaScript as the default language to implement the behaviour of the actors. **Simply said: the behaviour is a *function*.**

As a language, JavaScript is probably not the one every developer is dreaming about, but it has strong properties for an actor-based programming model:

* **Dynamic language**: JS is not statically typed nor compiled, which allows adopting easily an agile development approach for actors.
* **First-class functions**: JS allows passing functions as parameters so that injecting a behavior into an actor, a child actor for example, is a simple task.

#### References explicitely resolve remote actors

> TODO

#### Children

> TODO

### Wiring actors together

#### Names and addresses

Since actors communicate using messages, we need to know their *name*  and their *address* so we can can properly deliver these messages to their expected recipients.

**Each *name* or *address* MUST be unique inside a group of actors that need to collaborate.**

**Each actor can have multiple addresses.**

Hubiquitus adopts the following IETF standards for formating the *names* and *addresses* of actors:

* each *address* MUST comply with the [**Uniform Resource Location**](http://tools.ietf.org/html/rfc3986) IETF standard. For example, the following string is a valid actor's *address*: `http://*:8888`

#### Adapters

In order to be able to send and receive messages, actors need a transport layer. 

Hubiquitus provides a wide range of wire transport protocols, each of them being implemented by specialized JavaScript objects called *adapters*.

Hubiquitus distinguished two kind of adapters:

* the **inbound adapters**, that provide transports to the actors inboxes so that they can receive messages (and in some special cases "reply" to these messages)
* the **outbound adapters**, that provide transports to the actors behaviours so that they can send messages (and in some special cases get a "response").

Each adapter declares a unique *URL pattern* that Hubiquitus will use to match with addresses.

Consider for example a *HTTPAdapter* implementing the HTTP protocol. It would logically declare the following URL pattern: `http://*` so that any HTTP URL will match it (for example, the `http://127.0.0.1:8888` URL address matches the *HTTPAdapter*).

> TO COME HERE: list of the adapters available with their properties, the URL pattern matching rules, etc. ; links to the code.

Developers are free to add or extend Hubiquitus with their own adapters.

##### *Inbound adapters*

*Inbound adapters* act as inbox plugins for actors. They are responsible for binding the behaviour of the actor to every message received at an address.

Each time an actor is created, Hubiquitus will create as many inbound adapters as addresses declared by the actor. For each actor's address, Hubiquitus will instanciate an inbound adapter that match the address URL among the list of the supported adapters.

At actor's startup, Hubiquitus will also automatically start its inbound adapters. While starting, inbound adapters will:

* **bind the behaviour function to I/O events** that could occur on a given protocol and port (for example, the `HTTPAdapter` created for the `http://*:8888` address will start listening on port 8888 using the HTTP transport protocol) so that the behaviour will be triggered every time an incoming message is received.  
* **register themselves to a *tracker***, providing the name of the actor and the address it is listening to, so that other actors can further discover that address.

When the actor stops, Hubiquitus will also stop its inbound adapters. While stopping, inbound adapters will **unregister themselves to every tracker**, thus indicating that they will not be reachable anymore.

> Note: this mechanism is completely masked to the developer since it is implemented by the Hubiquitus engine (API functions involved: `start`, `touchTrackers`, `send` and `lookup`)

> TO COME HERE: schema of the principles explained above ; list of the inbound adapters available with their properties, the URL pattern they match, etc ; links to the code

##### *Outbound adapters*

*Outbound adapters* are created on-demand when actors ask for sending messages.

Each time an actor wants to send a message to another actor, Hubiquitus will:

* **query a tracker for the addresses of the recipient** (*TODO: document the rules that apply for selecting the address when multiple addresses are resolved*)
* **launch an outbound adapter that match the URL address** and pass it the message to send

Once launched, outbound adapters:

* are kept alive and reused for further sends, thus avoiding unnecessary lookups 
* listen for events published by the *tracker*  regarding the recipient address to detect recipient failures. 

> Note: this mechanism is completely masked to the developer since it is implemented by the Hubiquitus engine (API functions involved: `send` and `lookup`)

> TO COME HERE: schema of the principles explained above ; list of the outbound adapters available with their properties, the URL pattern they match, etc. ; links to the code

### Topology of Hubiquitus apps

#### From actors to apps - the 'russian dolls'

The structure of Hubiquitus apps take the form of a "russian doll" with four nested levels:

* `actor`: actors are the smallest building part of an application; they implement the elementary blocks of logic that are necessary to implement the features of the app,
* `process`: actors live in single-threaded processes; a single process can host an unlimited number of actors, as far as there's a sufficient amount of memory available.
* `program`: for various reasons, actors may be distributed on multiple processes running on a same host. for example, the child of an actor can be hosted in a forked process. These linked processes constitute what we call a program.
* `application`: hubiquitus apps are distributed applications that involve potentially many programs and many hosts

The following figure summarize this topology:

![hubiquitus exec model](https://github.com/hubiquitus/hubiquitus-reference/raw/master/docs/images/HubiquitusExecModel.png)

#### The root and the forest

We said that a process hosts multiple actors, but we need to be more precise: a process host only one `root actor` which itself potentially creates somes children, which themselves potentially create grandchildren, which themselves…and so one.

We can say that **each process hosts the root of a tree of actors**. With the multiple processes it involves, **an application can be see as a forest of actors**.  

#### Child actors and child processes

Actors are free to create as many child actors they want. These actors can either be created:

* **in the same running process**: the child actor is created in the same process as its parent
* **in a new process**: the child actor runs in its own process that has been forked from the  parent process.

In both cases, child actors are stopped and destroyed when the parent actor's process stops.

> note: to come in future versions (i) the ability to host a child in a process that already exists (ii) the ability to host a child actor in a processs that is not a "child" process

## The Hubiquitus API

> TO COME

## Implementation details


### The `hactor`object

Most of the Hubiquitus magic lay behind a single JavaScript objet called `hactor` that defines the structure common to every Hubiquitus actors:

* `actor id`: a **unique** key that identifies the actor, a simple string formatted like an URN,
* `behavior`: a **Javascript calllback** that is fired each time the actor receives a message,
* `endpoints`: a set of **addresses** onto which the actor will accept incoming messages
* `state`: an in-memory object that holds the state of the actor and onto which the behavior can make reads and writes,
* `children`: a list of references to child actors that could have been created by this actor
* `trackers`: a list of references to 'tracker' actors, a special actors that maintain the address book of all the actors

### Your first actor

All you have to do to create an actor is to instanciate this object with the following parameters:

* a unique actor **ID**
* a list of **one or more URLs** - the actor's inbound endpoints - that the actor will listen to for incoming messages,
* a **custom JavaScript callback** - the actor's behavior - that will be fired each time a message is received.

Once instanciated, you just have to start your actor and begin sending it messages, *et voilà* !

```js
// 	Instanciate your actor
var MyActor = require('hubiquitus').hactor(
	{ id: "myactor@localhost", in:["tcp://*.8888"]},
	function(err, message){
		// code your behavior below
	});

// Starting your actor
MyActor.start();
```
