## About the filewatcher Adapter

The filewatcher adapter is an adapter which watch a JSON file and send a property to an actor.

## Topology

You can add a filewatcher adapter to your actor by completing the specifics attributes in your actor topology.

```json
{
    "actor": "urn:domain:myActor",
    "type": "myActor",
    adapters: [ { type: "filewatcherAdapter", properties: {path:"./test.json"}, "serializer":"jsonpayload"} ]
}
```

In this example the adapter attribute is :

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
            <td><em>Value : filewatcherAdapter</em></td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>properties</td>
            <td>object</td>
            <td>
                The properties of the Filewatch adapter, depending of the path to watch
            </td>
            <td>Yes</td>
        </tr>
         <tr>
            <td>serializer</td>
            <td>String</td>
            <td>
                The serializer to use here, jsonPayload. For more information about serializers see <a href="https://github.com/hubiquitus/hubiquitus/tree/master/docs/serializers">here</a>
            </td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>

* File path properties :

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
            <td>path</td>
            <td>String</td>
            <td>File path to watch</td>
            <td>Yes</td>
        </tr>
        
    </tbody>
</table>

## API documentation

If you want to go deeper in Hubiquitus Filewatcher Adapter, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods


