# sudo apt-get update
# sudo apt-get install libudunits2-dev libgdal-dev libgeos-dev libproj-dev

library(shiny)
library(bslib)
library(tidyverse)
library(leaflet)
library(sf)

ta <- read_rds("data/ta_out.rds") %>%
  mutate(dummy = 1)
sa2 <- read_rds("data/sa2_out.rds") %>%
  mutate(dummy = 1)

ignore = c(
  "population",
  "TALB2023_1",
  "TALB2023_2",
  "TALB2023_1_copy",
  "area",
  "geometry",
  "dummy")

var_list <- c(
  "Select to explore",
  colnames(ta)[!colnames(ta) %in% ignore]
)

base_leaflet_options <- leafletOptions(zoomControl = FALSE,
                                       minZoom = 6,
                                       maxZoom = 15)
base_leaflet_highlight <- highlightOptions(stroke = TRUE,
                                           color = "#822218",
                                           opacity = 0.9,
                                           weight = 2,
                                           bringToFront = FALSE,
                                           sendToBack = TRUE)

