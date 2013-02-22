# Hubiquitus

## Features

* Clients can connect using WebSockets, allowing to use the best
transport for the client type.

* By using **Hubiquitus4js** (or one of the othe hAPI) you can simplify the treatment of messages sent
and let **Hubiquitus** take care of the rest.

* Several ports can be used for each transport, each running as a different
process increasing scalability!

## How to Install
### Dependencies

To use **Hubiquitus**, you need Node.JS, mongoDb, ZeroMQ and CoffeeScript :

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

* To install correctly CoffeeScript you can use `npm install -g coffee-script`

###Installation

```
$ npm install git://github.com/hubiquitus/hubiquitus.git
```

## How to use

* See our [Getting Start](https://github.com/hubiquitus/hubiquitus/tree/master/docs/GettingStart) > (Coming Soon)
* See Hubiquitus [Data structure](https://github.com/hubiquitus/hubiquitus/tree/master/docs/DataStructure)
* See the details about our [Actors](https://github.com/hubiquitus/hubiquitus/tree/master/docs/actors/hActor) > (Coming Soon)

This server needs a hAPI counterpart (ported to different languages),
for example [hubiquitus4js](https://github.com/hubiquitus/hubiquitus4js).


## License

Copyright (c) Novedia Group 2012.

This file is part of Hubiquitus

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

You should have received a copy of the MIT License along with Hubiquitus.
If not, see <http://opensource.org/licenses/mit-license.php>.
