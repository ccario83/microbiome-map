width = 960
height = 500
window.pies = []
window.piekeys = undefined
window.svg = null
window.projection = null

window.plot_pies = (bin, size) ->
  bin = (if typeof bin isnt "undefined" then bin else false)
  size = (if typeof size isnt "undefined" then size else 1.0)
  try
    size = parseFloat(size)
  catch
    alert("Please use a floating number for bin size.")
    return
  if (size <0.0 or size >4.0)
    alert("Please use a bin size between 0.0 and 4.0 degrees.")
    return
  if size == 0.0
    bin = false

  d3.select("#map").selectAll("g").remove()
  d3.select("#pie_legend").selectAll("div").remove()
  new_pies = []
  pies.forEach( (pie) ->
    loc = [(parseFloat(pie['loc'][0]) - 1.5), (parseFloat(pie['loc'][1]) - 1.0)]
    #loc = [(parseFloat(pie['loc'][0]) - 0.0), (parseFloat(pie['loc'][1]) - 0.0)]
    new_pies.push({"loc":loc, "vals":pie['vals']})
  )

  new_pies = bin_em(new_pies, size) if bin

  new_pies.forEach( (pie) ->
    make_pie(pie['vals'], pie['loc'])
  )

  color = d3.scale.category20()
  for idx in d3.range(0,piekeys.length)
    if piekeys[idx] is "Longitude" or piekeys[idx] is "Latitude"
      continue
    d3.select("#pie_legend")
      .append("div")
      .append("div")
      .attr("class","color_box")
      .attr("style","fill:"+color(idx))
      .append("div")
      .attr("class","legend_text")
      .text(piekeys[idx])
      .attr("style","color:"+color(idx))


make_pie = (dataset, loc) ->
  projection.scale(1040)
  width = 10
  height = 10
  radius = Math.min(width, height) / 2
  color = d3.scale.category20()
  pie = d3.layout.pie().sort(null)
  arc = d3.svg.arc()
    .innerRadius(radius - 5)
    .outerRadius(radius - 0)

  svg.append("g").selectAll("path")
    .data(pie(dataset))
    .enter()
    .append("path")
    .attr("fill", (d, i) -> color i)
    .attr("d", arc)
    .attr("transform", () -> "translate(" + projection(loc) + ")")


bin_em = (pies, step) ->
  lons = $.map(pies, (i) -> parseFloat(i['loc'][0]))
  lats = $.map(pies, (i) -> parseFloat(i['loc'][1]))

  binned = {}
  for lon_bin in d3.range(d3.min(lons),d3.max(lons),step)
    for lat_bin in d3.range(d3.min(lats),d3.max(lats),step)
      for pie in pies
        lon = pie['loc'][0]
        lat = pie['loc'][1]
        if lon >= lon_bin and lon < (lon_bin + step)
          if lat >= lat_bin and lat < (lat_bin + step)
            if binned[lon_bin+"_"+lat_bin] == undefined
              binned[lon_bin+"_"+lat_bin] = [pie['vals']]
            binned[lon_bin+"_"+lat_bin].push(pie['vals'])

  new_pies = []
  for ent in d3.entries(binned)
    #console.log("====")
    #console.log(ent)
    loc = ent['key'].split("_")
    vals = []
    sums = []
    counts = []
    #console.log("Binning")
    for val in ent['value']
      #console.log(val)
      for idx in d3.range(0,val.length)
        #console.log("looking at", val[idx])
        if sums[idx] == undefined
          sums[idx] = parseFloat(val[idx])
          counts[idx] = 1
        else
          sums[idx] += parseFloat(val[idx])
          counts[idx] += 1
        #console.log("Sum, count:",sums,counts)
    for idx in d3.range(0,sums.length)
      vals.push(parseFloat(sums[idx])/parseFloat(counts[idx]))
    new_pies.push({'loc':loc, "vals":vals})
  new_pies

ready = (error, us) ->
  window.projection = d3.geo.conicConformal()
    .rotate([98, 0])
    .center([0, 38])
    .parallels([29.5, 45.5])
    .scale(1000)
    .translate([width / 2, height / 2])
    .precision(.4)

  path = d3.geo.path().projection(projection)

  graticule = d3.geo.graticule().extent([[-98 - 45, 38 - 45], [-98 + 45, 38 + 45]]).step([5, 5])


  path = d3.geo.path()
  window.svg = d3.select("#map")
    .append("svg")
    .attr("width", width)
    .attr("height", height)

  svg.append("path")
    .datum(graticule)
    .attr("class", "graticule")
    .attr "d", path

  svg.insert("path", ".graticule")
    .datum(topojson.feature(us, us.objects.land))
    .attr("class", "land")
    .attr "d", path
  
  svg.insert("path", ".graticule")
    .datum(topojson.mesh(us, us.objects.counties, (a, b) ->
      a isnt b and not (a.id / 1000 ^ b.id / 1000)))
    .attr("class", "county-boundary")
    .attr "d", path
  
  svg.insert("path", ".graticule")
    .datum(topojson.mesh(us, us.objects.states, (a, b) -> true))
    .attr("class", "state-boundary")
  .attr "d", path

  plot_pies()

  d3.select(self.frameElement).style "height", height + "px"



queue()
  .defer(d3.json, "/json/us_counties.json")
  .defer(d3.csv, $('#datafile').text(), (d) ->
    window.piekeys = d3.keys(d) if window.piekeys is undefined
    loc = [d.Longitude, d.Latitude]
    values = []
    d3.keys(d).forEach( (k) ->
      if k is "Latitude" or k is "Longitude"
        true
      else
        values.push(d[k])
    pies.push({"loc":loc, "vals":values})
    )
  ).await ready

$('.menu').dropit()
$('.menu').show()