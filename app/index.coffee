require('lib/setup')

Spine = require('spine')
MapController = require("controllers/MapController")
ControlsController = require('controllers/ControlsController')

class App extends Spine.Controller
  constructor: ->
    super

    mc = new MapController({el:'#map'})
    @append new ControlsController()


module.exports = App
    