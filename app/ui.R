custom_theme <- bslib::bs_theme(version = 5,
                                bootswatch = "litera")

style_navbar <- "
      .navbar {
        --bs-navbar-active-color: #2d3a31;
        --bs-navbar-color: #59685e;
        --bs-navbar-hover-color: #306918;
        --bs-navbar-brand-color: #2d3a31;
        --bs-navbar-brand-hover-color: #2d3a31;
      }"

ui <- page_navbar(
  title = tagList("Aotearoa Census 2023 Explorer",img(src="nz_transp_.png",height=45)),
  id="main",
  theme = custom_theme,
  bg="#a1b997",
  nav_panel(
    title="Explore",
    id="explore",
    explore_ui("explore"),
    tags$head(
      # Note the wrapping of the string in HTML()
      tags$style(HTML(style_navbar)))),
  nav_panel(
    title="Compare",
    id="compare"#,
    # compare_ui("compare")
  )
)
