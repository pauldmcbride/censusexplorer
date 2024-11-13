explore_ui <- function(id) {

  ns = NS(id)

  card(
    card_header(
      selectizeInput(ns("var"), NULL, choices=var_list)
    ),
    card_body(
      leafletOutput(ns("explore_map"))      )
  )

}


explore_server <- function(id) {

  moduleServer(id, function(input, output, session) {

    var <- reactive({
      if_else(input$var == var_list[1], "dummy", input$var)
    })

    leaflet_ <- reactive({

    pal_sa2 <- palette_maker(domain = sa2[[var()]])
    pal_ta <- palette_maker(domain = ta[[var()]])

      leaflet(options = base_leaflet_options)  %>%
        addProviderTiles(providers$CartoDB.Voyager) %>%
        addPolygons(data=ta,
                    fillColor = ~pal_ta(ta[[var()]]),
                    color = ~"black",
                    weight = 1,
                    smoothFactor = 0.5,
                    opacity = 0.2,
                    fillOpacity = 0.65,
                    layerId = ~TALB2023_1,
                    highlightOptions = base_leaflet_highlight,
                    group = "ta") %>%
        addPolygons(data=sa2,
                    fillColor = ~pal_sa2(sa2[[var()]]),
                    color = ~"black",
                    weight = 1,
                    smoothFactor = 0.5,
                    opacity = 0.1,
                    fillOpacity = 0.65,
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
        groupOptions("ta", zoomLevels = seq(from=6, to= 9, by=0.1)) %>%
        groupOptions("sa2", zoomLevels = seq(from=9.1, to= 15, by=0.1)) %>%
        groupOptions("ta_in", zoomLevels = seq(from=9.1, to= 15, by=0.1))

  })

    output$explore_map <- renderLeaflet(
      leaflet_()
    )

  })}
