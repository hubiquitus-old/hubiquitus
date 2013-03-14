## About the hGateway actor

The hGateway actor is our connector actor.
His purpose is to be an connexion way for all client using an hAPI (so connecting to the hEngine with socket-IO)

> Note that an hGateway actor must have an hAuth actor as child

## Topology

The hGateway actor, like all actor, extend our hActor class so he has the same topology's attributes.
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
            <td>socketIOPort</td>
            <td>Integer</td>
            <td>The port listen by the actor to communicate with socket-IO</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>authActor</td>
            <td>String</td>
            <td>URN of the actor which have to manage the authentication</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>authTimeout</td>
            <td>Integer</td>
            <td>Delay before considering the authentication failed</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>

Examples :

* Minimum topology :

```json
{
    "actor": "urn:localhost:myGateway",
    "type": "hgateway",
    "children": [
        {
            "actor": "urn:localhost:auth",
            "type": "hauth"
        }
    ],
    "adapters": [ { "type": "socket_in", "url": "tcp://127.0.0.1:3993" } ],
    "properties": {
        "socketIOPort": 8080,
        "authActor": "urn:localhost:myAuth",
        "authTimeout": 3000
    }
}
```
> A gateway always need a socket_in adapter

* Complete topology :

```json
{
    "actor": "urn:localhost:myGateway",
    "type": "hgateway",
    "method": "inproc",
    "log":{
        "logLevel":"debug"
    },
    "children": [
        {
            "actor": "urn:localhost:auth",
            "type": "hauth"
        }
    ],
    "adapters": [ { "type": "socket_in", "url": "tcp://127.0.0.1:3993" } ],
    "properties": {
        "socketIOPort": 8080,
        "authActor": "urn:localhost:myAuth",
        "authTimeout": 3000
    }
}
```

## API documentation

If you want to go deeper in Hubiquitus hGateway, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods

