Spine = require('spine')

class ControlsController extends Spine.Controller
  className: "controls"

  constructor: ->
    super
    @currentRegion = "home"
    @render()
    Spine.bind("regionChanged", @updateRegion)

  render:=>
    @html require('views/controls')
      region : @currentRegion
  
  updateRegion:(region)=>
    @currentRegion = region.properties
    @render()

module.exports = ControlsController