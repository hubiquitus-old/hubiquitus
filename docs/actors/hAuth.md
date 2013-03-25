## About the hAuth actor

The hAuth actor is our basic authentication actor.
His purpose is to check the authorization of an client using an hAPI to connect to the hEngine.
In basic authentication, a client is authorized when login equals password.
If you want a more advanced authentication, you need to extend this class and overload the auth method

> Note that a hAuth actor must be a child of a hGateway actor

## Topology

The hAuth actor, like all actors, extends our hActor class so he has the same topology's attributes.

Examples :

* Minimum topology :

```json
{
    "actor": "urn:domain:myAuth",
    "type": "myAuth"
}
```
* Complete topology :

```json
{
    "actor": "urn:domain:myAuth",
    "type": "myAuth",
    "method": "inproc",
    "log": {
        "logLevel": "info",
        "logFile": "./myLogFile.log"
    }
}
```

## API documentation

If you want to go deeper in Hubiquitus hAuth, see the complete [API documentation](http://coffeedoc.info/github/hubiquitus/hubiquitus/master/) which describe class variables and methods

