width = 960
height = 500
rateById = d3.map()

ready = (error, us) ->
  quantize = d3.scale.quantize()
  .domain([d3.min(rateById.values()), d3.max(rateById.values())])
  .range(d3.range(9)
  .map((i) ->
    "q" + i + "-9"
  ))

  svg.append("g")
    .attr("class", "counties")
    .selectAll("path")
    .data(topojson.feature(us, us.objects.counties).features)
    .enter()
    .append("path")
    .attr("class", (d) ->
      quantize rateById.get(d.id)
    )
    .attr "d", path

  svg.append("path")
    .datum(topojson.mesh(us, us.objects.states, (a, b) ->
      a isnt b 
    ))
    .attr("class", "states").attr "d", path


path = d3.geo.path()
svg = d3.select("body")
  .append("svg")
  .attr("width", width)
  .attr("height", height)

queue()
  .defer(d3.json, "/json/us_counties.json")
  .defer(d3.tsv, $('#datafile').text(), (d) ->
    rateById.set String(+d.FIPS), +d[d.Variable] / 100
  ).await ready

$('.menu').dropit()
$('.menu').show()