\name{duckmap}
\alias{duckmap}
\title{Generate duckmapR palette colors}
\usage{
duckmap(
  palette = NULL,
  type = "all",
  n = NULL,
  reverse = FALSE,
  style = c("standard", "vivid"),
  colors = NULL,
  warn_even_divergent = TRUE
)
}
\arguments{
\item{palette}{Optional palette name. Sequential and divergent palettes can be called directly by name. The default categorical palette is called \code{"archetype"}.}
\item{type}{Palette type. Accepted values are \code{"all"}, \code{"seq"}/\code{"sequential"}, \code{"div"}/\code{"divergent"}, and \code{"cat"}/\code{"categorical"}. Defaults to \code{"all"}, which resolves supplied palette names across palette classes.}
\item{n}{Number of colors to return. If \code{NULL}, defaults are type-aware: 256 for sequential palettes, 257 for divergent palettes, and the full categorical palette length for categorical colors.}
\item{reverse}{Logical; if \code{TRUE}, reverse the palette.}
\item{style}{Sequential palette style. Use \code{"standard"} or \code{"vivid"}. The vivid style is only available for sequential palettes.}
\item{colors}{Optional character vector of named categorical colors to select when using the categorical palette.}
\item{warn_even_divergent}{Logical; if \code{TRUE}, warn when an even \code{n} is requested for a divergent palette because the exact white midpoint will not be sampled.}
}
\value{A character vector of sRGB hex colors.}
\description{Generate colors from duckmapR sequential, divergent, or categorical palettes.}
\examples{
duckmap("full_plumage", n = 9)
duckmap("full_plumage", n = 9, style = "vivid")
duckmap("orange_blue", n = 11)
duckmap("archetype")
duckmap(type = "divergent")
duckmap(type = "categorical", colors = c("mallard_teal", "soft_gold"))
}
