## About the timer Adapter

The timer adapter is used to generate hMessage and send it to the actor every period (depending properties)
It can be use with two mode :

* millisecond : a hMessage will be generate every X milliseconds
* crontab : a hMessage will be generate by a [cron](https://npmjs.org/package/cron)

## Topology

You can add a timer adapter to your actor by completing the specifics attributes in your actor topology.

```json
{
    "actor": "urn:domain:myActor",
    "type": "myActor"
    "adapters": [ { "type": "timerAdapter", "properties": {...} } ],
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
            <td>properties</td>
            <td>Object</td>
            <td>The properties of the timer adapter, depending the mode use by the adapter
            </td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>

* Millisecond mode properties :

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
            <td>alert</td>
            <td>String</td>
            <td>The name of the hAlert send by the timer adapter</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>mode</td>
            <td>String</td>
            <td><em>Value : millisecond</em></td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>period</td>
            <td>Integer</td>
            <td>Delay between two timer alert</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>

* Crontab mode properties :

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
            <td>alert</td>
            <td>String</td>
            <td>The name of the hAlert send by the timer adapter</td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>mode</td>
            <td>String</td>
            <td><em>Value : crontab</em></td>
            <td>Yes</td>
        </tr>
        <tr>
            <td>crontab</td>
            <td>String</td>
            <td>Cron to apply to the timer</td>
            <td>Yes</td>
        </tr>
    </tbody>
</table>



## API documentation

If you want to go deeper in Hubiquitus timer Adapter, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods
