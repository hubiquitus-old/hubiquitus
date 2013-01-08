# The ubiquitous framework for your context-aware live apps

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

Hubiquitus aims to provide a simple way to develop apps that fulfill with these requirements. It is basically an ubiquitous programming model for building context-aware distributed live apps.

* **actor-based apps**: applications developed using Hubiquitus are basically made of actors, a lightweight form of concurrent computational entities that sequentially process messages from an event-driven receive loop called a Reactor. Each actor makes its own decisions regarding what to do with incoming messages.
* **JavaScript SDK**: the dynamic scripting language of the web may not be the perfect language we all dream about, but it is undoubtedly the most ubiquitous one. It allows developers to code apps that are able to reach practically any device running a JavaScript engine.
* **message-driven communication**: like humans, Hubiquitus actors are autonomous entities which state is not share nor synchronized with other actors state. This "share nothing" strategy is enforced by using an asynchronous message-driven communication between actors. Hubiquitus actors can exchange messages through either a point-to-point, a request-reply, a publish-subscribe, a master-worker strategy or a combination of these patterns. Hubiquitus also provides a dynamic content-based message filtering system.
* **p2p connections**: Hubiquitus adopts a broker-less P2P distribution model in which actors discover and connect each other dynamically at runtime, thus allowing to implement easily resilient and elastic architectures. Peering also provides more direct connections which contribute to reduce communication latency.
* **fast & lightweight transport**: actors connect each other using various forms of sockets used to transport messages using a very small footprint transport protocol  ; the combination of PGM, TCP and HTML5 Web sockets allows covering most network topologies.
* **historical data**: the whole messaging history is transparently persisted into a NoSQL database.
* **bridges to the outside world**: even JavaScript can't run on every platforms, so Hubiquitus provides native bindings for major platforms such as iOS, Android and Windows 8. Hubiquitus also provides a wide range of network adapters allowing to integrate your apps with social networks (Twitter, Google+, …), push notification services (APNS, GCM, …)

### We stand on the shoulders of giants!

Hubiquitus gets its fabulous power from of mix of well-known magical (and also free and open source) ingredients...

* [NodeJS](nodejs.org): the Hubiquitus actors engine runs on top of the great NodeJS evented programming platform.
* MongoDB: Hubiquitus uses Mongo as its underlying store for persisting context data
* [0MQ](zeromq.org): the socket-based messaging library is the core transport layer of Hubiquitus
* SocketIO: websockets are not always available so SIO helps in providing transparently fallback transports.