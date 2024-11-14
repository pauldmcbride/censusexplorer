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

    map <- leaflet() %>%
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
                   group = "ta_in")

        var <- reactive({
      if_else(input$var == var_list[1], "dummy", input$var)
    })

        map_bounds_ <- reactive({
          input$explore_map_bounds
        })

        map_zoom_ <- reactive({
          input$explore_map_zoom
        })

        current_ta <- reactiveVal("none")
        proxy_ta <- reactiveVal("none")
        proxy_var <- reactiveVal("dummy")


        add_layer <- eventReactive(list(map_bounds_(), map_zoom_()), {

          if(!is.null(map_zoom_()) && map_zoom_() >= 10) {
            map_lat = mean(map_bounds_()[c(1,3)] %>% as.numeric)
            map_lng = mean(map_bounds_()[c(2,4)] %>% as.numeric)
            pt = sf::st_point(x=c(map_lng,map_lat)) %>%
              sf::st_buffer(0.4)
            ta_ = st_intersects(pt, ta$geometry) %>% unlist %>% as.numeric()
          } else {
            ta_ = NA
          }
          if(any(!is.na(ta_))) {
            add_layer_ <- sa2[sa2$ta %in% ta$TALB2023_1[ta_],]
            current_ta(ta_)
          } else {
            add_layer_ <- data.frame()
            current_ta("none")
          }
          print(add_layer_)
          add_layer_
        })

        observeEvent(list(var(),add_layer()), {

          pal_sa2 <- palette_maker(domain = sa2[[var()]])
          pal_ta <- palette_maker(domain = ta[[var()]])

          if(is_empty(add_layer())) {
            sa2_in <- sa2[1,]
            sa2_opacity <- 0
          } else {
            sa2_in <- add_layer()
            sa2_opacity <- 0.35
          }

          if(!identical(var(), proxy_var())  | !identical(current_ta(),proxy_ta())) {
            leafletProxy("explore_map", session) %>%
              clearGroup(group="sa2") %>%
              clearGroup(group="ta") %>%
              addPolygons(data=sa2_in,
                          fillColor = ~pal_sa2(sa2_in[[var()]]),
                          weight = 1,
                          smoothFactor = 0.5,
                          opacity = 0.2,
                          fillOpacity = sa2_opacity,
                          color = ~"black",
                          layerId = ~SA22023_V1,
                          highlightOptions = base_leaflet_highlight,
                          group="sa2") %>%
              addPolygons(data=ta[!ta$TALB2023_1 %in% add_layer()$ta,],
                          fillColor = ~pal_ta(ta[[var()]]),
                          weight = 1,
                          smoothFactor = 0.5,
                          opacity = 0.2,
                          fillOpacity = 0.35,
                          color = ~"black",
                          layerId = ~TALB2023_1,
                          highlightOptions = base_leaflet_highlight,
                          group="ta")
            proxy_ta(current_ta())
            proxy_var(var())
          }
        })

  #   leaflet_ <- reactive({
  #
  #   pal_sa2 <- palette_maker(domain = sa2[[var()]])
  #   pal_ta <- palette_maker(domain = ta[[var()]])
  #
  #     leaflet(options = base_leaflet_options)  %>%
  #       addProviderTiles(providers$CartoDB.Voyager) %>%
  #       addPolygons(data=ta,
  #                   fillColor = ~pal_ta(ta[[var()]]),
  #                   color = ~"black",
  #                   weight = 1,
  #                   smoothFactor = 0.5,
  #                   opacity = 0.2,
  #                   fillOpacity = 0.65,
  #                   layerId = ~TALB2023_1,
  #                   highlightOptions = base_leaflet_highlight,
  #                   group = "ta") %>%
  #       addPolygons(data=sa2,
  #                   fillColor = ~pal_sa2(sa2[[var()]]),
  #                   color = ~"black",
  #                   weight = 1,
  #                   smoothFactor = 0.5,
  #                   opacity = 0.1,
  #                   fillOpacity = 0.65,
  #                   layerId = ~SA22023_V1,
  #                   highlightOptions = base_leaflet_highlight,
  #                   group = "sa2") %>%
  #       addPolylines(data=ta,
  #                    color = ~"black",
  #                    weight = 2.5,
  #                    smoothFactor = 0.5,
  #                    opacity = 0.2,
  #                    layerId = ~TALB2023_1_copy,
  #                    group = "ta_in") %>%
  #       groupOptions("ta", zoomLevels = seq(from=6, to= 9, by=0.1)) %>%
  #       groupOptions("sa2", zoomLevels = seq(from=9.1, to= 15, by=0.1)) %>%
  #       groupOptions("ta_in", zoomLevels = seq(from=9.1, to= 15, by=0.1))
  #
  # })

    output$explore_map <- renderLeaflet(
      map
    )

  })}
