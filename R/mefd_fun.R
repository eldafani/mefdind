#' metadata de indicadores
#' @export
#' @description
#' Genera metadata para indicadores a partir de url del MEFD: nombre de archivos,
#' urls de archivos, nombre del indicador
#'
#' @param url_web url de página web del MEFD con lista de indicadores
#' @param config lista con parámetros de configuración (default)
#' @return tibble con metadatos
#' @importFrom rvest html_attr html_elements html_text read_html
#' @importFrom stringr str_match
#'
#' @examples
#' mi_url <- paste0("https://estadisticas.educacion.gob.es/EducaDynPx/",
#' "educabase/index.htm?type=pcaxis&path=/no-universitaria/centros/",
#' "centrosyunid/series/unidades_esc&file=pcaxis&l=s0")
#' mi_meta <- mefd_meta(mi_url)
mefd_meta <- function(url_web, config = conf) {

pg <- read_html(url_web)

### Titulo de la pagina web
tit <- rvest::html_elements(pg, "h1")
tit <- trimws(rvest::html_text(tit))

### Nodos <a
pg_a <- rvest::html_elements(pg, "a")

### Titulo de base de datos del indicador
tit_ind <- sapply(pg_a, function(x) stringr::str_match(as.character(x), conf$tit_p)[,2])
tit_ind <- unique(tit_ind[!is.na(tit_ind)])

### Nombre de archivos .csv
file <- mefd_name(url_web=url_web, config = conf)
myurl <- mefd_url(url_web=url_web)

### tibble metadata
df <- data.frame(tit_ind, file, myurl, tit)
names(df) <- c("indicador", "archivo", "url", "titulo")
return(df)
}

#' Nombre de indicadores
#' @export
#' @description
#' Genera vector con nombre de bases de datos (.csv) para cada indicador
#' a partir de url de la web
#'
#' @param url_web url de página web del MEFD con lista de indicadores
#' @param config lista con parámetros de configuración (default)
#' @return vector con el nombre de los archivos .csv
#' @importFrom rvest html_attr html_elements html_text read_html
#' @importFrom stringr str_match
#'
#' @examples
#' mi_url <- paste0("https://estadisticas.educacion.gob.es/EducaDynPx/",
#' "educabase/index.htm?type=pcaxis&path=/no-universitaria/centros/",
#' "centrosyunid/series/unidades_esc&file=pcaxis&l=s0")
#' mefd_name(mi_url)
mefd_name <- function(url_web, config = conf) {

### Lee atributos 'href'(ruta de la tabla)
  pg <- read_html(url_web)
  pg_a <- rvest::html_elements(pg, "a")

  href <- rvest::html_attr(pg_a, "href")
  href <- href[!is.na(href)]
  href <- href[nchar(href)>1]
  href <- grep(conf$tabpx, href, value = TRUE)

### Extrae nombre del archivo .csv
  file <- unique(stringr::str_match(href, conf$file_p)[,2])
  file <- file[!is.na(file)]
  file <- paste0(file, ".csv")
  return(file)
}

#' url de indicadores
#' @export
#' @description
#' Genera vector con urls de bases de datos (.csv) para cada indicador
#' a partir de url de la web
#'
#' @param url_web url de página web del MEFD con lista de indicadores
#' @param config lista con parámetros de configuración (default)
#' @return vector con urls de bases de datos (.csv)
#' @importFrom rvest html_attr html_elements html_text read_html
#' @importFrom stringr str_match
#'
#' @examples
#' mi_url <- paste0("https://estadisticas.educacion.gob.es/EducaDynPx/",
#' "educabase/index.htm?type=pcaxis&path=/no-universitaria/centros/",
#' "centrosyunid/series/unidades_esc&file=pcaxis&l=s0")
#' mefd_url(mi_url)
mefd_url <- function(url_web, config = conf) {

### Lee atributos 'href'(ruta de la tabla)
  pg <- rvest::read_html(url_web)
  pg_a <- rvest::html_elements(pg, "a")

  href <- rvest::html_attr(pg_a, "href")
  href <- href[!is.na(href)]
  href <- href[nchar(href)>1]
  href <- grep(conf$tabpx, href, value = TRUE)

### Extrae nombre del archivo .csv
  file <- unique(stringr::str_match(href, conf$file_p)[,2])
  file <- file[!is.na(file)]
  file <- paste0(file, ".csv")

### Genera url para .csv
  url_3 <- paste0(unique(stringr::str_match(href, conf$pre_p)[,2]), "/")
  base_url <- paste0(conf$url_1, conf$url_2, url_3)
  myurl <- paste0(base_url, file, conf$suf_url)
  return(myurl)
}

#' Lee datos de indicadores
#' @export
#' @description
#' Lee bases de datos (.csv) de indicadores a partir de id de la serie (idserie),
#' página web (url_web) o url de .csv (url_ind). El usuaRio debe eligir solo un método.
#'
#' @param idserie id de la serie en el archivo de metadatos (meta_mefd)
#' @param url_ind url(s) de la bases de datos (.csv) del indicador
#' @param url_web url de página web del MEFD con lista de indicadores
#' @param config lista con parámetros de configuración (default)
#' @return data.frame o lista de data.frames con datos de indicadores
#' @importFrom rvest html_attr html_elements html_text read_html
#' @importFrom stringr str_match
#' @importFrom utils read.csv2
#'
#' @examples
#' mi_url <- paste0("https://estadisticas.educacion.gob.es/EducaDynPx/",
#' "educabase/index.htm?type=pcaxis&path=/no-universitaria/centros/",
#' "centrosyunid/series/unidades_esc&file=pcaxis&l=s0")
#'
#' # Lectura con el id de la serie
#' df <- mefd_read(idserie = 11109)
#' df <- mefd_read(idserie = c(11109, 11125, 37002))
#'
#' # Lectura desde página web (url_web)
#' df <- mefd_read(url_web = mi_url)
#'
#' # Lectura de un indicador específico a partir de url del .csv (url_ind)
#' df <- mefd_read(url_ind = meta_mefd$url[190])
#'
#' # Lectura de varios indicadores a partir del url del .csv (url_ind)
#' df <- mefd_read(url_ind=meta_mefd$url[c(1, 5, 17)])
mefd_read <- function(idserie = NULL, url_ind = NULL, url_web = NULL, config = conf) {

### Error si indican más de un método o ninguno
  if(sum(!sapply(list(idserie, url_ind, url_web), is.null)) != 1) {
    message("You need to supply one argument only: 'idserie', 'url_ind', or 'url_web'")
    return(NULL)
  }

### Lee datos con idserie
  if(!is.null(idserie)) {
    mimeta <- meta_mefd[meta_mefd$idserie %in% idserie, ]
    if(length(idserie)==1) {
      df <- cbind(read.csv2(url(mimeta$url)), indicador = mimeta$indicador)
    } else {
      df <- lapply(1:nrow(mimeta), function(x)
      cbind(read.csv2(url(mimeta$url[[x]])), indicador =  mimeta$indicador[[x]]))
      names(df) <- mimeta$idserie
    }
    return(df)
}

### Lee datos con url de la .csv (sin nombrar)
  if(!is.null(url_ind)) {
    if(length(url_ind)==1) {
    df <- read.csv2(url(url_ind))
    } else {
    df <- lapply(url_ind, function(x) read.csv2(url(x)))
    }
    return(df)
  }

### Lee datos con url de la pagina web (nombrando)
  if(!is.null(url_web)) {
    url_vec <- mefd_url(url_web=url_web, config = conf)
    df <- lapply(url_vec, function(x) read.csv2(url(x)))
    names(df) <- mefd_name(url_web=url_web, config = conf)
    return(df)
  }
}


#' Descarga datos de indicadores
#' @export
#' @description
#' Descarga bases de datos (.csv) de indicadores a partir de id de la serie (idserie),
#' página web (url_web) o url de .csv (url_ind). El usuaRio debe eligir solo un método.
#'
#' @param idserie id de la serie en el archivo de metadatos (meta_mefd)
#' @param url_ind url(s) de la bases de datos (.csv) del indicador
#' @param url_web url de página web del MEFD con lista de indicadores
#' @param folder directorio donde guardar los datos
#' @param config lista con parámetros de configuración (default)
#' @return data.frame o lista de data.frames con datos de indicadores
#' @importFrom rvest html_attr html_elements html_text read_html
#' @importFrom stringr str_match
#' @importFrom utils read.csv2 download.file
#'
#' @examples
#' \donttest{
#' mi_folder <- "/home/datos"
#' mi_url <- paste0("https://estadisticas.educacion.gob.es/EducaDynPx/",
#' "educabase/index.htm?type=pcaxis&path=/no-universitaria/centros/",
#' "centrosyunid/series/unidades_esc&file=pcaxis&l=s0")
#'
#' # Descarga con id de la serie
#' mefd_down(idserie = 11109, folder = mi_folder)
#' mefd_down(idserie = c(11109, 11125, 37002), folder = mi_folder)
#'
#' # Descarga desde página web (url_web)
#' mefd_down(url_web = mi_url, folder = mi_folder)
#'
#' # Descarga un indicador específico a partir de url del .csv (url_ind)
#' mefd_down(url_ind = meta_mefd$url[190], folder = mi_folder)
#'
#' # Descarga varios indicadores a partir del url del .csv (url_ind)
#' mefd_down(url_ind=meta_mefd$url[c(1, 5, 17)], folder = mi_folder)
#' }
mefd_down <- function(idserie = NULL, url_ind = NULL, url_web = NULL, folder = tempdir(), config = conf) {

### Error si indican más de un método o ninguno
  if(sum(!sapply(list(idserie, url_ind, url_web), is.null)) != 1) {
    message("You need to supply one argument only: 'idserie', 'url_ind', or 'url_web'")
    return(NULL)
  }

### Lee datos con idserie
  if(!is.null(idserie)) {
    mimeta <- meta_mefd[meta_mefd$idserie %in% idserie, ]
    if(length(idserie)==1) {
    df <- download.file(url = mimeta$url,
          destfile = file.path(folder, paste0(mimeta$idserie, ".csv")))
    } else {
    df <- lapply(1:nrow(mimeta), function(x) download.file(url = mimeta$url[[x]],
          destfile = file.path(folder, paste0(mimeta$idserie[[x]], ".csv"))))
    }
  }

  ### Lee datos con url de la .csv (sin nombrar)
  if(!is.null(url_ind)) {
    if(length(url_ind)==1) {
      df <- download.file(url = url_ind, destfile = file.path(folder, "datos.csv"))
    } else
      df <- lapply(seq_along(url_ind), function(x) download.file(url = url_ind[[x]],
            destfile = file.path(folder, paste("datos_", x, ".csv"))))
  }

  ### Lee datos con url de la pagina web (nombrando)
  if(!is.null(url_web)) {
    url_vec <- mefd_url(url_web=url_web, config = conf)
    name_vec <- mefd_name(url_web=url_web, config = conf)
    df <- lapply(seq_along(url_vec), function(x) download.file(url = url_vec[[x]],
    destfile = file.path(folder, name_vec[[x]])))
  }
}

#' Buscador de indicadores
#' @export
#' @description
#' Busca en archivo metadatos el nombre de indicadores que contienen una palabra
#'
#' @param value palabra a buscar en la lista de indicadores
#' @param config lista con parámetros de configuración (default)
#' @return data.frame con el nombre y idserie de los indicadores
#'
#' @examples
#' # Indicadores que contienen la palabra "idoneidad"
#' mefd_search("idoneidad")
#' # Indicadores que contienen la palabra "primaria"
#' mefd_search("primaria")
#' # Indicadores que contienen las palabra "primaria" y "sexo
#' mefd_search("primaria.*sexo")
#' # Indicadores que contienen las palabra "extranjero" o "idoneidad"
#' mefd_search("extranjero|idoneidad")
mefd_search <- function(value, config = conf) {
  index <- grep(iconv(tolower(value), to="ASCII//TRANSLIT"),
                iconv(tolower(meta_mefd$indicador), to="ASCII//TRANSLIT"))
  output <- meta_mefd[index, c("idserie", "indicador")]
  return(output)
}
