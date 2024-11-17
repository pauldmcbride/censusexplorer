palette_maker <- function(ramp=c(

  # Original - fill opacity should be quite low
  #"blue",
  # "green",
  # "red"

  # Another promising option
  "#1958e1",
  "#2a8598",
  "#32b478",
  "#99cf49",
  "#ecea43",
  "#ecc843",
  "#d61b4d"

  # A third, possibly more neutral option
  # "#003f5b",
  # "#2b4b7d",
  # "#5f5195",
  # "#98509d",
  # "#cc4c91",
  # "#f25375",
  # "#ff6f4e",
  # "#ff9913"
),
domain = sa2[[item]]) {

  if(length(unique(domain)) == 1) {
    ramp=c('grey','grey', 'grey')
  }
  colorNumeric(palette = colorRampPalette(ramp)(length(domain)),
               domain = domain)
}


map_start <- function() {
  leaflet() %>%
    leaflet(options = base_leaflet_options)  %>%
    addProviderTiles(providers$CartoDB.Voyager) %>%
    addPolygons(data=ta,
                fillColor = "grey",
                color = ~"black",
                weight = 1,
                smoothFactor = 0.5,
                opacity = 0.2,
                fillOpacity = 0.35,
                layerId = ~TALB2023_1,
                highlightOptions = base_leaflet_highlight,
                group = "ta") %>%
    addPolygons(data=sa2[1,],
                fillColor = ~"grey",
                color = ~"black",
                weight = 1,
                smoothFactor = 0.5,
                opacity = 0.1,
                fillOpacity = 0,
                layerId = ~SA22023_V1,
                highlightOptions = base_leaflet_highlight,
                group = "sa2") %>%
    addPolylines(data=ta,
                 color = ~"black",
                 weight = 2.5,
                 smoothFactor = 0.5,
                 opacity = 0.2,
                 layerId = ~TALB2023_1_copy,
                 group = "ta_in") %>%
addControl("Showing territorial authorities",
           position = "topleft") %>%
    groupOptions("ta_in", zoomLevels = seq(from=9.9, to= 15, by=0.1))

}
