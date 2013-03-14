(function() {
    var factory, main;

    require("coffee-script");

    factory = require("./hfactory");

    main = function() {
        var actor, actorProps, args;
        args = process.argv.slice(2);
        actorProps = JSON.parse(args[1]);
        actor = factory.newActor(args[0], actorProps);
        process.send({
            state: "ready"
        });
        return process.on("message", function(msg) {
            return actor.emit("message", msg);
        });
    };

    main();

}).call(this);
