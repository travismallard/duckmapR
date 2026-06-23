\name{duckmap_summary}
\alias{duckmap_summary}
\title{Draw a visual summary of duckmapR palettes}
\usage{
duckmap_summary(type = "all", plot = TRUE, style = c("standard", "vivid"))
}
\arguments{
\item{type}{Palette type. Accepted values are \code{"all"}, \code{"seq"}/\code{"sequential"}, \code{"div"}/\code{"divergent"}, and \code{"cat"}/\code{"categorical"}.}
\item{plot}{Logical; if \code{TRUE}, draw a visual summary. If \code{FALSE}, return palette metadata.}
\item{style}{Sequential palette style to show: \code{"standard"} or \code{"vivid"}. Vivid style is only available for sequential palettes.}
}
\value{Palette metadata invisibly when \code{plot = TRUE}; otherwise a data frame.}
\description{Draw a compact visual summary of available duckmapR palettes.}
\examples{
duckmap_summary()
duckmap_summary(type = "divergent")
duckmap_summary(style = "vivid")
duckmap_summary(plot = FALSE)
}
