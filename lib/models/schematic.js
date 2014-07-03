mongoose = require('mongoose')

SchematicSchema = new mongoose.Schema ({
    id: String
  }, {strict: false});

module.exports = mongoose.model('Schematic', SchematicSchema)
