## Features

* Clients can connect using WebSockets, allowing to use the best transport for the client type.

* By using [**Hubiquitus4js**](https://github.com/hubiquitus/hubiquitus4js) (or one of the othe hAPI) you can simplify the treatment of messages sent
and let **Hubiquitus** take care of the rest.

* Several ports can be used for each transport, each running as a different
process increasing scalability!

## How to Install
### Dependencies

To use **Hubiquitus**, you need [Node.JS](http://nodejs.org), [mongoDb](http://www.mongodb.org), [ZeroMQ](http://www.zeromq.org) :

* To install correctly Node.JS you can use this [link](https://github.com/joyent/node/wiki/Installation)

> Note that you need at least v0.8.0

> Warning : Do not install Node.JS with `sudo apt-get install nodejs`

* To install correctly MongoDB database you can use `sudo apt-get install mongodb`

* To install correctly ZeroMQ follow the next steps :

```
tar -zxf zeromq-3.2.2.tar #Download this from zeromq.org
cd zeromq-3.2.2
./configure
make
sudo make install
```
> Note that you need at least v3.2.2

###Installation

If you just want to use Hubiquitus without modifying it, you are ready. You can build your Hubiquitus project.

If you want to join us and work on Hubiquitus, you can do :

```
$ git clone git://github.com/hubiquitus/hubiquitus.git
```
## Running an example

Before running your example you need to include `hubiquitus`. You have two ways to do it. In your workspace :
* If you have a local version of hubiquitus (previously clone with git or download from our repository) :
```
$ npm install ./hubiquitus
```
> `./hubiquitus` is the path of your local version

* If you don't have a local version of hubiquitus you can use :
```
$ npm install git://github.com/hubiquitus/hubiquitus.git
```
or
```
$ npm install hubiquitus
```

Then include `coffee-script` using :

```
$ npm install coffee-script
```

At this step, you should have in your workspace :
* A `node_modules` folder containing hubiquitus and coffee-script

You now need to build your launch file :

```js
require("coffee-script");
require("./node_modules/hubiquitus/lib/hubiquitus").start("./node_modules/hubiquitus/samples/sample1.json");
```

You are now ready to run your example. To do it, you can execute your launch file in WebStorm (or an other IDE), or use the following command line in your workspace :

```
$ node launch.js
```

Hubiquitus is now running. You can use any of our hAPI to send or receive hMessage

## Building your own hubiquitus projet

### Building your own actor

Hubiquitus provides some specific actor to build your project. But if our actors are not enough for your needs, you can build and use your own actor

> You can find details about our hubiquitus actor [here](https://github.com/hubiquitus/hubiquitus/tree/master/docs/actors)

Every Hubiquitus's actors are write in Coffee-Script. You have to put all your own actors in an `actors` folder in your Workspace

To build your actor, you just need to extend Actor class of Hubiquitus and override needed function :

```coffee-script
{Actor} = require "hubiquitus"

class myActor extends Actor

  constructor: (topology) ->
    super #This instruction is mandatory to correctly start your actor
    @type = 'myActor'

  onMessage: (hMessage) ->
    console.log "myActor receive a hMessage", hMessage

exports.myActor = myActor
exports.newActor = (topology) ->
  new myActor(topology)
```

> You can override some over functions depending your needs, for more details about these functions see [hActor](https://github.com/hubiquitus/hubiquitus/tree/master/docs/actors/hActor.md)

### Building your own adapter

Hubiquitus provide some specific adapter to allow communication between actors or with external API (like Twitter). But if our adapters are not enough for your needs, you can build an use you own adapters.

> You can find details about our Hubiquitus adapter [here](https://github.com/hubiquitus/hubiquitus/tree/master/docs/adapters)

Every Hubiquitus's adapters are write in Coffee-Script.

You can build inbound adapter or outbound adapter. You have to put all your own adapters in an `adapters` folder in your Workspace

> If you adapter is both IN and OUT, build an outbound adapter

To build your inbound adapter, you just need to extend InboundAdapter class of Hubiquitus and override needed function :

```coffee-script
{InboundAdapter} = require("hubiquitus").adapter

class myInboundAdapter extends InboundAdapter

  constructor: (properties) ->
    super
    # Add your initializing instructions

  start: ->
    unless @started
      # Add your starting instructions
      # To send the hMessage to the actor use : @owner.emit "message", hMessage
      super

  stop: ->
    if @started
      # Add your stopping instructions
      super

exports.myInboundAdapter = myInboundAdapter
exports.newAdapter = (properties) ->
  new myInboundAdapter(properties)
```

To build your inbound adapter, you just need to extend OutboundAdapter class of Hubiquitus and override needed function :

```coffee-script
{OutboundAdapter} = require("hubiquitus").adapter

class myOutboundAdapter extends OutboundAdapter

  constructor: (properties) ->
    super
    # Add your initializing instructions

  start: ->
    unless @started
      # Add your starting instructions
      super

  stop: ->
    if @started
      # Add your stopping instructions
      super

  send: (message) ->
    # Add your sending instruction

exports.myOutboundAdapter = myOutboundAdapter
exports.newAdapter = (properties) ->
  new myOutboundAdapter(properties)
```
> You can override some over functions depending your needs, for more details about these functions see [Adapters](https://github.com/hubiquitus/hubiquitus/tree/master/docs/adapters/hAdapters.md)

### Building your project's topology

When all your actors and adapters are build and you have think about your project architecture, you are ready to build your topology.

You can find a topology sample [here](https://github.com/hubiquitus/hubiquitus/tree/master/samples/myProject/myTopology.json) and detail about actor's topology [here](https://github.com/hubiquitus/hubiquitus/tree/master/docs/actors)

### Running your project

We will run a sample project which you can find in [myProject](https://github.com/hubiquitus/hubiquitus/tree/master/samples/myProject)

Before running your project you need to include `hubiquitus`. You have two ways to do it. In your workspace :
* If you have a local version of hubiquitus (previously clone with git or download from our repository) :
```
$ npm install ./hubiquitus
```
> `./hubiquitus` is the path of your local version

* If you don't have a local version of hubiquitus you can use :
```
$ npm install git://github.com/hubiquitus/hubiquitus.git
```
or
```
$ npm install hubiquitus
```

Then include `coffee-script` using :

```
$ npm install coffee-script
```

At this step, you should have in your workspace :
* An `actors` folder containing all your own actors (optional)
* An `adapters` folder containing all your own adapters (optional)
* A `node_modules` folder containing hubiquitus and coffee-script
* A topology file in `json`

You now need to build your launch file :

```js
require("coffee-script");
require("hubiquitus").start("./myTopology.json");
```

You are now ready to run your project. To do it, you can execute your launch file in WebStorm (or an other IDE), or use the following command line in you workspace :

```
$ node launch.js
```
