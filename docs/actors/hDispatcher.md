## About the hDispatcher actor

The hDispatcher actor is our load balancing actor.
His purpose is to distribute the load on few identical actor called worker.


## Topology

The hDispatcher actor, like all actor, extend our hActor class so he has the same topology's attributes.
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
            <td>workers</td>
            <td>Object</td>
            <td>The properties of the workers to launch</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>

Workers properties :
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
            <td>method</td>
            <td>String</td>
            <td>The method use to create the workers.<br/>
                Possible values :
                <ul>
                    <li>"inproc" : The actor will be create in the same process</li>
                    <li>"fork" : The actor will be create in a new process</li>
                </ul>
            </td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>type</td>
            <td>String</td>
            <td>The type of the actor which will be create as worker</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>nb</td>
            <td>Integer</td>
            <td>Number of worker which will be create</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>

Examples :

* Minimum topology :

```json
{
    "actor": "urn:localhost:myDispatcher",
    "type": "hdispatcher",
    "properties": {
        "workers": { "method": "fork", "type": "hactor", "nb": 2 }
    },
    "adapters": [ { "type": "socket_in", "url": "tcp://127.0.0.1:2992" } ]
},
```
> A dispatcher always need a socket_in adapter

* Complete topology :

```json
{
    "actor": "urn:localhost:myDispatcher",
    "type": "hdispatcher",
    "method": "inproc",
    "log": {
        "logLevel": "info",
        "logFile": "./myLogFile.log"
    },
    "properties": {
        "workers": { "method": "fork", "type": "hactor", "nb": 2 }
    },
    "adapters": [ { "type": "socket_in", "url": "tcp://127.0.0.1:2992" } ]
}
```

## API documentation

If you want to go deeper in Hubiquitus hDispatcher, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods

