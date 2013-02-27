actors = {}

exports.withActor = (type, actor) ->
  if actors[type] then throw new Error "actor '#{type}' already defined"
  actors[type] = actor

exports.newActor = (type, properties) ->
  if not actors[type] then actors[type] = require("./actor/#{type}")
  actors[type].newActor properties