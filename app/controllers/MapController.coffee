Spine = require('spine')

class MapController extends Spine.Controller
  elemnets:
    ".map_center" : 'mapCenter'

  constructor: ->
    super 
    @append("<div id='mainMap'></div>")
    @setUpMap()
    @loadRegions()


  setUpMap:->
    @leafletMap = new L.Map('mainMap')

    @cloudmade = new L.TileLayer 'http://{s}.tile.cloudmade.com/703a104d15d44e2885f6cedeaaec6d30/60297/256/{z}/{x}/{y}.png'
      maxZoom: 18
    @leafletMap.addLayer(@cloudmade)

    @setUpCarto()
    @geojson = new L.GeoJSON();

    @leafletMap.addLayer(@geojson)

    @leafletMap.setView new L.LatLng(51.505, -0.09), 5
    
    @leafletMap.on "dragend", =>
      @getRegionLocal @leafletMap.getCenter()

    @leafletMap.on "zoom", =>
      @getRegionLocal @leafletMap.getCenter()


  setUpCarto:->
    cartodb_leaflet = new L.CartoDBLayer
      map_canvas: 'map_canvas'
      map: @leafletMap
      user_name:"zooniverse"
      table_name: 'uk_admin_simple_export'
      query: "SELECT cartodb_id,the_geom_webmercator,name_ascii FROM {{table_name}}"
      tile_style: "uk_admin_simple_export{polygon-fill: #18B2E6;polygon-opacity: 0.7;line-opacity:1;line-color: #FFFFFF;}}"
      auto_bound: false
      debug: false

  loadRegions:=>
    query = "SELECT * FROM uk_admin_simple_export"
    
    $.getJSON "http://zooniverse.cartodb.com/api/v1/sql?q="+query+"&format=geojson&callback=?",(data) =>        
      @regions = data.features
    
      window.regions = @regions


  getRegionLocal: (location)=>
    if @regions?
      testLocation = {longitude : -4.49 , latitude : 55.61 }
      for region ,index in @regions
        geom = region.regionGeom
        for subregion in geom
        # console.log "testing region ", region.properties.name_ascii
          # console.log "testing subregion ",subregion  if index ==0
          if geolib.isPointInside(location,subregion)
            console.log('inside ', region.properties.name_ascii)

  getRegionData:(center)=>
    query = "SELECT * FROM uk_admin_simple_export where ST_Intersects(the_geom,GeometryFromText('Point("+center.lng+" "+center.lat+")',4326)) Order By shape_area ASC" 
  
    $.getJSON "http://zooniverse.cartodb.com/api/v1/sql?q="+query+"&format=geojson&callback=?",(data) =>
      console.log("got server reply",data )
      if data.features? and data.features.length > 0
        @drawRegion(data.features[0])
        Spine.trigger "regionChanged", data.features[0] 


  drawRegion:(region)=>
    @geojson.addGeoJSON(region)

module.exports = MapController