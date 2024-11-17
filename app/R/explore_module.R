explore_ui <- function(id) {

  ns = NS(id)

  layout_column_wrap(
    width = NULL,
    style = css(grid_template_columns = "70% 30%"),
  card(
    card_header(
      selectizeInput(ns("var"), NULL, choices=var_list)
    ),
    card_body(
      leafletOutput(ns("explore_map"))
      )
  ),
  card(
    card_header(
      "Head placeholder"
    ),
    card_body(
      "Body placeholder")
      )
  )
}


explore_server <- function(id) {

  moduleServer(id, function(input, output, session) {

  map <- map_start()

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
      add_layer_
    })

    observeEvent(list(var(),add_layer()), {

      pal_sa2 <- palette_maker(domain = sa2[[var()]])
      # pal_ta <- palette_maker(domain = ta[[var()]])

      if(is_empty(add_layer())) {
        sa2_in <- sa2[1,]
        sa2_opacity <- 0
      } else {
        sa2_in <- add_layer()
        sa2_opacity <- main_opacity
      }
      ta_trim_ <- ta[!ta$TALB2023_1 %in% add_layer()$ta,]
      if(!identical(var(), proxy_var())  | !identical(current_ta(),proxy_ta())) {
        leafletProxy("explore_map", session) %>%
          clearGroup(group="sa2") %>%
          clearGroup(group="ta") %>%
          clearControls() %>%
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
          addPolygons(data=ta_trim_,
                      fillColor = ~pal_sa2(ta_trim_[[var()]]),
                      weight = 1,
                      smoothFactor = 0.5,
                      opacity = 0.2,
                      fillOpacity = main_opacity,
                      color = ~"black",
                      layerId = ~TALB2023_1,
                      highlightOptions = base_leaflet_highlight,
                      group="ta") %>%
          addControl(if_else(map_zoom_() >=10,
                             "Showing communities (statistical area 2)",
                             "Showing territorial authorities"),
                     position = "topleft") %>%
          addControl(var(),
                     position = "topright") %>%
          addLegend(layerId = "legend_polygon",
                    data=sa2,
                    position = "topright",
                    pal = pal_sa2,
                    values = ~na.omit(sa2[[var()]]),
                    title = " ",
                    na.label = NULL)
        proxy_ta(current_ta())
        proxy_var(var())
      }
    })

    output$explore_map <- renderLeaflet(
      map
    )

  })}
