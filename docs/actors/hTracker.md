## About the hTracker actor

The hTracker actor is our router actor.
His purpose is to know all the actors in the system and inform them about the other peer and their state.

## Topology

The hTracker actor, like all actors, extends our hActor class so he has the same topology's attributes.
But he always has specifics properties :
<table>
    <thead>
        <tr>
            <th>Property</th>
            <th>Type</th>
            <th>Description</th>
            <th>Mandatory</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>channel</td>
            <td>Object</td>
            <td>The topology of the trackChannel (a hChannel)</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>

Examples :

* Minimum topology :

```json
{
    "actor": "urn:localhost:myTracker",
    "type": "hTracker",
    "adapters": [ { "type": "socket_in", "url": "tcp://127.0.0.1:3993" } ],
    "properties": {
        "channel": {
            "actor": "urn:localhost:trackChannel",
            "type": "hchannel",
            "properties": {
                "listenOn": "tcp://127.0.0.1",
                "broadcastOn": "tcp://127.0.0.1",
                "subscribers": [],
                "db":{
                    "host": "localhost",
                    "port": 27017,
                    "name": "admin"
                },
                "collection": "trackChannel"
            }
        }
    }
}
```
> A tracker always needs a socket_in adapter

* Complete topology :

```json
{
    "actor": "urn:localhost:myTracker",
    "type": "hTracker",
    "method": "inproc",
    "log":{
        "logLevel":"debug"
    },
    "adapters": [ { "type": "socket_in", "url": "tcp://127.0.0.1:3993" } ],
    "properties": {
        "channel": {
            "actor": "urn:localhost:trackChannel",
            "type": "hchannel",
            "properties": {
                "listenOn": "tcp://127.0.0.1",
                "broadcastOn": "tcp://127.0.0.1",
                "subscribers": [],
                "db":{
                    "host": "localhost",
                    "port": 27017,
                    "name": "admin"
                },
                "collection": "trackChannel"
            }
        }
    }
}
```

## API documentation

If you want to go deeper in Hubiquitus hTracker, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods

