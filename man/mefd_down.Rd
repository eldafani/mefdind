% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mefd_fun.R
\name{mefd_down}
\alias{mefd_down}
\title{Descarga datos de indicadores}
\usage{
mefd_down(
  idserie = NULL,
  url_ind = NULL,
  url_web = NULL,
  folder = tempdir(),
  config = conf
)
}
\arguments{
\item{idserie}{id de la serie en el archivo de metadatos (meta_mefd)}

\item{url_ind}{url(s) de la bases de datos (.csv) del indicador}

\item{url_web}{url de página web del MEFD con lista de indicadores}

\item{folder}{directorio donde guardar los datos}

\item{config}{lista con parámetros de configuración (default)}
}
\value{
data.frame o lista de data.frames con datos de indicadores
}
\description{
Descarga bases de datos (.csv) de indicadores a partir de id de la serie (idserie),
página web (url_web) o url de .csv (url_ind). El usuaRio debe eligir solo un método.
}
\examples{
\donttest{
mi_folder <- "/home/datos"
mi_url <- paste0("https://estadisticas.educacion.gob.es/EducaDynPx/",
"educabase/index.htm?type=pcaxis&path=/no-universitaria/centros/",
"centrosyunid/series/unidades_esc&file=pcaxis&l=s0")

# Descarga con id de la serie
mefd_down(idserie = 11109, folder = mi_folder)
mefd_down(idserie = c(11109, 11125, 37002), folder = mi_folder)

# Descarga desde página web (url_web)
mefd_down(url_web = mi_url, folder = mi_folder)

# Descarga un indicador específico a partir de url del .csv (url_ind)
mefd_down(url_ind = meta_mefd$url[190], folder = mi_folder)

# Descarga varios indicadores a partir del url del .csv (url_ind)
mefd_down(url_ind=meta_mefd$url[c(1, 5, 17)], folder = mi_folder)
}
}
