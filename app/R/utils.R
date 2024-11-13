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
