mongoose = require 'mongoose'
Schematic = require '../models/schematic'

module.exports.getSchematic = (req, res) ->
  Schematic.find (err, schematics) ->
    return res.json(err) if err?

    if (schematics.length > 0)
      return res.json(schematics[0])
    else
      return res.json('{}')

module.exports.postSchematic = (req, res) ->
  console.log req.body
  Schematic.remove {}, (err) ->
    schema = new Schematic req.body
    schema.save (err, doc) ->
      console.log err if err?

      res.status 200
      res.send()
