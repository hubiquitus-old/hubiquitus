## About the socket_in Adapter

The socket_in adapter is the basic listening adapter. Every actor needs one to exchange messages.

## Topology

You can add a socket_in adapter to your actor by completing the specifics attributes in your actor topology.

```json
{
    "actor": "urn:domain:myActor",
    "type": "myActor"
    "adapters": [ { "type": "socket_in", "url": "tcp://127.0.0.1:3993" } ],
}
```

In this example the adapters attributes are :

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
            <td>type</td>
            <td>String</td>
            <td><em>Value : socket_in</em></td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>url</td>
            <td>String</td>
            <td>
                The url listening by the adapter
                <em>If you don't add a port, it will be automatically set</em>
            </td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>


## API documentation

If you want to go deeper in Hubiquitus socket_in Adapter, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods
