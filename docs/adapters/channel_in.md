## About the channel_in Adapter

The channel_in adapter is used when a actor subscribes to a channel

## Topology

There are two ways to create a channel_in adapter to your actor :
* By completing the specifics attributes in your actor topology
* By calling the subscribe method

```json
{
    "actor": "urn:domain:myActor",
    "type": "myActor"
    "adapters": [ { "type": "channel_in", "channel": "urn:domain:myChannel", "quickFilter": "" } ],
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
            <td><em>Value : channel_in</em></td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>url</td>
            <td>String</td>
            <td>
                The URN of the channel to listen
                <em>If you don't add a port, it will be automatically set</em>
            </td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>quickFilter</td>
            <td>String</td>
            <td>
                The quickFilter to apply to the subscription (like a topic)
                <em>Default value : ""</em>
            </td>
            <td>No</td>
        </tr>
    </tbody>
</table>


## API documentation

If you want to go deeper in Hubiquitus channel_in Adapter, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods
