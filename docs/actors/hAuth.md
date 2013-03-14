## About the hAuth actor

The hAuth actor is our basic authentication actor.
His purpose is to be check the authorization of an client using an hAPI to connect to the hEngine.
In basic authentication, a client is authorize when login egal password.
If you want a more advance authentication, you need to extend this class and overload the auth method

> Note that an hAuth actor must be a child of an hGateway actor

## Topology

The hAuth actor, like all actor, extend our hActor class so he has the same topology's attributes.

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

