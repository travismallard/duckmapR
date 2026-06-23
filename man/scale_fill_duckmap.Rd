\name{scale_fill_duckmap}
\alias{scale_fill_duckmap}
\title{ggplot2 fill scale using duckmapR palettes}
\usage{
scale_fill_duckmap(
  palette = NULL,
  type = "all",
  discrete = NULL,
  reverse = FALSE,
  style = c("standard", "vivid"),
  colors = NULL,
  ...
)
}
\arguments{
\item{palette}{Optional palette name. Sequential and divergent palettes can be called directly by name.}
\item{type}{Palette type. Accepted values are \code{"all"}, \code{"seq"}/\code{"sequential"}, \code{"div"}/\code{"divergent"}, and \code{"cat"}/\code{"categorical"}.}
\item{discrete}{Logical; if \code{TRUE}, use a discrete scale. If \code{NULL}, categorical palettes use a discrete scale and sequential/divergent palettes use continuous scales.}
\item{reverse}{Logical; reverse the palette.}
\item{style}{Sequential palette style: \code{"standard"} or \code{"vivid"}.}
\item{colors}{Optional categorical color names to select when using the categorical palette.}
\item{...}{Additional arguments passed to the ggplot2 scale.}
}
\value{A ggplot2 scale object.}
\description{Create a ggplot2 fill scale using duckmapR palettes.}
\examples{
if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  ggplot(faithfuld, aes(waiting, eruptions, fill = density)) +
    geom_raster() +
    scale_fill_duckmap("viriduck")
}
}
