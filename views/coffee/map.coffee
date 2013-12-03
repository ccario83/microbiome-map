width = 960
height = 500
rateById = d3.map()

ready = (error, us) ->
  quantize = d3.scale.quantize()
  .domain([d3.min(rateById.values()), d3.max(rateById.values())])
  .range(colorbrewer.Greens[9])

  svg.append("g")
    .attr("class", "counties")
    .selectAll("path")
    .data(topojson.feature(us, us.objects.counties).features)
    .enter()
    .append("path")
    .attr("fill", (d) ->
      quantize rateById.get(d.id)
      console.log(quantize rateById.get(d.id))
      console.log(rateById.get(d.id))
      console.log(d.id)
      console.log("----")
    )
    .attr "d", path

  svg.append("path")
    .datum(topojson.mesh(us, us.objects.states, (a, b) ->
      a isnt b 
    ))
    .attr("class", "states").attr "d", path

  domain = d3.range(quantize.domain()[0],quantize.domain()[1],(quantize.domain()[1]-quantize.domain()[0])/(quantize.range().length-1))
  domain.push(quantize.domain()[1])
  legend = d3.select('#legend')
    .append('ul')
    .attr('class', 'list-inline')
    .selectAll('li.key')
    .data(quantize.range())
    .enter().append('li')
    .attr('class', 'key')
    .style('border-left-color', String)
    .text( (d) ->
      (domain[(quantize.range().indexOf(d))]*100).toExponential(2)
    )
  true

path = d3.geo.path()

svg = d3.select("#map")
  .append("svg")
  .attr("width", width)
  .attr("height", height)

d3.select("#loading").remove()

queue()
  .defer(d3.json, "/json/us_counties.json")
  .defer(d3.tsv, $('#datafile').text(), (d) ->
    rateById.set String(+d.FIPS), (+d[d.Variable] / 100)
  ).await ready

$('.menu').dropit()
$('.menu').show()






