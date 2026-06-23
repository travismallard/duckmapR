\name{duckmap_info}
\alias{duckmap_info}
\title{Return duckmapR palette metadata}
\usage{
duckmap_info(type = "all")
}
\arguments{
\item{type}{Palette type. Accepted values are \code{"all"}, \code{"seq"}/\code{"sequential"}, \code{"div"}/\code{"divergent"}, and \code{"cat"}/\code{"categorical"}.}
}
\value{A data frame with palette name, type, default status, default \code{n}, and available styles.}
\description{Return structured metadata for available duckmapR palettes.}
\examples{
duckmap_info()
duckmap_info(type = "divergent")
}
