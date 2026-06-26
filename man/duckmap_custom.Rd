\name{duckmap_custom}
\alias{duckmap_custom}
\title{Define a custom duckmapR palette}
\usage{
duckmap_custom(anchors, name = "custom")
}
\arguments{
\item{anchors}{A data frame of CIELAB anchor colors with numeric columns \code{L}, \code{a}, and \code{b} (at least two rows). An optional numeric column \code{t} gives each anchor's relative position; values are sorted and rescaled to \code{[0, 1]}. If \code{t} is omitted, anchors are spaced evenly.}
\item{name}{Optional single string labelling the palette. Used only for display (the \code{print} method and ggplot2 scale naming); it is not required to use the palette. Defaults to \code{"custom"}.}
}
\value{A \code{duckmap_palette} object that can be passed as the \code{palette} argument to \code{\link{duckmap}}, \code{\link{scale_fill_duckmap}}, and \code{\link{scale_color_duckmap}}.}
\description{Build a continuous palette from user-supplied CIELAB anchors. Colors are interpolated in Lab space and converted to sRGB, the same way the built-in palettes are generated.}
\examples{
map <- duckmap_custom(
  anchors = data.frame(
    t = c(0, 0.333, 0.667, 1),
    L = c(20, 51, 70, 95),
    a = c(38, 21, 24, -1),
    b = c(-51, -25, 19, 3)
  ),
  name = "custom"
)

duckmap(map, n = 11)

library(ggplot2)
ggplot(faithfuld, aes(waiting, eruptions, fill = density)) +
  geom_raster() +
  scale_fill_duckmap(map)
}
\seealso{\code{\link{duckmap}}, \code{\link{scale_fill_duckmap}}, \code{\link{scale_color_duckmap}}}
