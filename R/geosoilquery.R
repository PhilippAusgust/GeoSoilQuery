#' GeoSoilQuery
#'
#' Eine R6-Klasse für schnelle räumliche Abfragen geologischer Parameter auf Basis
#' des IGME5000-Datensatzes. Das zugrundeliegende Shapefile wird einmal geladen und
#' anschließend für Punkt- oder Batch-Abfragen wiederverwendet.
#'
#' @details
#' Die Klasse kapselt das Laden, Transformieren und räumliche Joinen eines großen
#' Geologie-Shapefiles und stellt eine einfache API für Einzelpunkte und ganze
#' DataFrames bereit. Optional wird ein Cache verwendet, um wiederholte Abfragen
#' zu beschleunigen.
#'
#' @section Usage:
#' \preformatted{
#' geo <- GeoSoilQuery$new(geology_path, crs_target = 4326, use_cache = TRUE)
#'
#' geo$query_geology(lat, lon)
#' geo$query_batch(df, lat_col = "Lat", lon_col = "Lon", params = NULL)
#' geo$get_available_parameters()
#' geo$cache_info()
#' geo$clear_cache()
#' }
#'
#' @section Datenquelle:
#' Die Beispiele verwenden den mitgelieferten Datensatz aus \code{inst/extdata/IGME5000}.
#' Der Zugriff erfolgt portabel über \code{system.file()}.
#'
#' @examples
#' library(GeoSoilQuery)
#'
#' # ------------------------------------------------------------------
#' # Data source: mitgelieferte IGME5000-Daten aus inst/extdata
#' # ------------------------------------------------------------------
#'
#' geology_path <- system.file(
#'   "extdata", "IGME5000", "europe", "data",
#'   "IGME5000_europeEPSG3034shp_geology_poly_v01.shp",
#'   package = "GeoSoilQuery"
#' )
#'
#' # Nur ausführen, wenn die Datei wirklich vorhanden ist
#' if (nzchar(geology_path) && file.exists(geology_path)) {
#'
#'   # --------------------------------------------------------------
#'   # Initialisierung der Query-Engine
#'   # --------------------------------------------------------------
#'
#'   geo <- GeoSoilQuery$new(
#'     geology_path = geology_path,
#'     crs_target   = 4326,
#'     use_cache    = TRUE
#'   )
#'
#'   # --------------------------------------------------------------
#'   # Einzelpunkt-Abfrage
#'   # --------------------------------------------------------------
#'
#'   # Beispielkoordinaten: Köln
#'   lat <- 50.9375
#'   lon <- 6.9603
#'
#'   res <- geo$query_geology(lat = lat, lon = lon)
#'   print(res)
#'
#'   # --------------------------------------------------------------
#'   # Batch-Abfrage für mehrere Standorte
#'   # --------------------------------------------------------------
#'
#'   df <- data.frame(
#'     Site = c("Koeln", "Berlin", "Muenchen"),
#'     Lat  = c(50.9375, 52.5200, 48.1372),
#'     Lon  = c(6.9603, 13.4050, 11.5756)
#'   )
#'
#'   out <- geo$query_batch(df, lat_col = "Lat", lon_col = "Lon")
#'   print(out)
#'
#'   # --------------------------------------------------------------
#'   # Cache-Informationen anzeigen und Cache leeren
#'   # --------------------------------------------------------------
#'
#'   geo$cache_info()
#'   geo$clear_cache()
#' }

#' @export
#' @importFrom R6 R6Class
#'
GeoSoilQuery <- R6::R6Class(
  "GeoSoilQuery",

  private = list(
    geology_poly = NULL,
    geology_poly_valid = NULL,
    query_cache = list(),

    validate_coords = function(lat, lon) {
      if (is.na(lat) || is.na(lon)) stop("Lat und Lon dürfen nicht NA sein")
      if (lat < -90 || lat > 90) stop("Latitude muss zwischen -90 und 90 liegen")
      if (lon < -180 || lon > 180) stop("Longitude muss zwischen -180 und 180 liegen")
      TRUE
    },

    make_cache_key = function(lat, lon, param_type) {
      paste(round(lat, 6), round(lon, 6), param_type, sep = "_")
    },


    as_df = function(info) {

      # FALL 1: kein Treffer
      if (!isTRUE(info$found)) {
        return(data.frame(
          found = FALSE,
          AgeName = NA_character_,
          Portr_AGE = NA,
          Portr_Petr = NA_character_,
          AgeOldest = NA,
          AgeNewest = NA,
          message = info$message %||% NA_character_,
          stringsAsFactors = FALSE
        ))
      }

      # FALL 2: Treffer
      data.frame(
        found = TRUE,
        AgeName = info$AgeName,
        Portr_AGE = info$Portr_AGE,
        Portr_Petr = info$Portr_Petr,
        AgeOldest = info$AgeOldest,
        AgeNewest = info$AgeNewest,
        stringsAsFactors = FALSE
      )
    }



  ),

  public = list(
    #' @field use_cache Logisch; wenn TRUE werden Abfrage-Ergebnisse gecacht.
    use_cache = TRUE,
    #' @field crs Integer; EPSG-Code des Koordinatensystems (Default: 4326).
    crs = 4326,

    #' @description
    #' Initialisiere die GeoSoilQuery-Klasse.
    #' @param geology_path Pfad zum geologischen Shapefile.
    #' @param crs_target Ziel-Koordinatensystem (default: 4326 für WGS84).
    #' @param use_cache Soll ein Cache verwendet werden? (default: TRUE).
    #' @return Ein GeoSoilQuery-Objekt.
    #' @importFrom sf st_read st_transform st_make_valid
    initialize = function(geology_path, crs_target = 4326, use_cache = TRUE) {
      message("Lade geologische Daten...")

      private$geology_poly <- sf::st_read(geology_path, quiet = TRUE)
      geology_transformed <- sf::st_transform(private$geology_poly, crs = crs_target)
      private$geology_poly_valid <- sf::st_make_valid(geology_transformed)

      message(sprintf("✓ %d geologische Features geladen", nrow(private$geology_poly_valid)))

      self$use_cache <- use_cache
      self$crs <- crs_target
      invisible(self)
    },

    #' @description
    #' Abfrage geologischer Parameter für einen einzelnen Punkt.
    #' @param lat Latitude (WGS84).
    #' @param lon Longitude (WGS84).
    #' @return Liste mit geologischen Attributen.
    #' @importFrom sf st_as_sf st_join st_intersects st_drop_geometry
    query_geology = function(lat, lon, return_df = FALSE) {
      private$validate_coords(lat, lon)

      cache_key <- private$make_cache_key(lat, lon, "geology")
      if (self$use_cache && !is.null(private$query_cache[[cache_key]])) {
        message("✓ Aus Cache geladen")
        info <- private$query_cache[[cache_key]]
        if (return_df) return(private$as_df(info))
        return(info)
      }


      point_sf <- sf::st_as_sf(
        data.frame(lon = lon, lat = lat),
        coords = c("lon", "lat"),
        crs = self$crs
      )

      result <- sf::st_join(point_sf, private$geology_poly_valid, join = sf::st_intersects)


      if (nrow(result) == 0 || all(is.na(sf::st_drop_geometry(result)[1, ]))) {
        info <- list(found = FALSE, message = "Keine geologischen Daten an dieser Koordinate")
      } else {
        info <- list(
          found = TRUE,
          AgeName = result$AgeName[1],
          Portr_AGE = result$Portr_AGE[1],
          Portr_Petr = result$Portr_Petr[1],
          AgeOldest = result$AgeOldest[1],
          AgeNewest = result$AgeNewest[1],
          all_attributes = as.list(sf::st_drop_geometry(result[1, ]))
        )
      }

      # Cache speichern (Liste)
      if (self$use_cache) private$query_cache[[cache_key]] <- info

      # Output nach Wunsch
      if (return_df) return(private$as_df(info))
      info
    },

    #' @description
    #' Batch-Abfrage für einen ganzen DataFrame.
    #' @param df DataFrame mit Lat/Lon Spalten.
    #' @param lat_col Name der Latitude-Spalte.
    #' @param lon_col Name der Longitude-Spalte.
    #' @param params Vektor der gewünschten Parameter.
    #' @return Erweiterter DataFrame mit geologischen Parametern.
    #' @importFrom sf st_as_sf st_join st_intersects st_drop_geometry
    #' @importFrom dplyr filter
    query_batch = function(df, lat_col = "Lat", lon_col = "Lon",
                           params = c("AgeName", "Portr_AGE", "Portr_Petr", "AgeOldest", "AgeNewest")) {

      message(sprintf("Starte Batch-Abfrage für %d Standorte...", nrow(df)))

      if (!lat_col %in% names(df) || !lon_col %in% names(df)) {
        stop(sprintf("Spalten '%s' und/oder '%s' nicht im DataFrame gefunden", lat_col, lon_col))
      }

      valid_coords <- df |>
        dplyr::filter(!is.na(.data[[lon_col]]) & !is.na(.data[[lat_col]]))

      if (nrow(valid_coords) == 0) stop("Keine gültigen Koordinaten im DataFrame gefunden")

      message(sprintf("→ %d gültige Koordinaten gefunden", nrow(valid_coords)))

      study_sites_sf <- sf::st_as_sf(valid_coords, coords = c(lon_col, lat_col), crs = self$crs)
      geo_joined <- sf::st_join(study_sites_sf, private$geology_poly_valid, join = sf::st_intersects)

      result_df <- sf::st_drop_geometry(geo_joined)

      available_params <- params[params %in% names(result_df)]
      if (length(available_params) < length(params)) {
        warning(sprintf(
          "Folgende Parameter nicht verfügbar: %s",
          paste(setdiff(params, available_params), collapse = ", ")
        ))
      }

      result_final <- cbind(valid_coords, result_df[, available_params, drop = FALSE])

      message(sprintf("✓ Batch-Abfrage abgeschlossen: %d Parameter hinzugefügt", length(available_params)))
      result_final
    },

    #' @description
    #' Zeige verfügbare Parameter im Shapefile.
    #' @return Character-Vektor mit Spaltennamen.
    get_available_parameters = function() {
      params <- names(private$geology_poly_valid)
      params[params != "geometry"]
    },

    #' @description
    #' Cache leeren.
    clear_cache = function() {
      private$query_cache <- list()
      message("✓ Cache geleert")
      invisible(NULL)
    },

    #' @description
    #' Cache-Statistiken anzeigen.
    cache_info = function() {
      n_entries <- length(private$query_cache)
      message(sprintf("Cache enthält %d Einträge", n_entries))
      invisible(n_entries)
    }
  )
)

#' Schnelle Einzelabfrage geologischer Parameter
#'
#' Wrapper-Funktion für einfache Einzelabfragen ohne manuelle Klasseninstanziierung.
#'
#' @param lat Latitude (WGS84).
#' @param lon Longitude (WGS84).
#' @param geology_path Pfad zum geologischen Shapefile.
#' @return Liste mit geologischen Attributen.
#' @export
get_geology_at <- function(lat, lon, geology_path, UseCache = FALSE, ReturnDF=TRUE) {
  query_engine <- GeoSoilQuery$new(geology_path, use_cache = UseCache)
  query_engine$query_geology(lat, lon, return_df = ReturnDF)
}

#' Geologische Parameter zu DataFrame hinzufügen
#'
#' Convenience-Funktion für Batch-Abfragen ohne explizite Klassennutzung.
#'
#' @param df DataFrame mit Koordinaten.
#' @param geology_path Pfad zum geologischen Shapefile.
#' @param lat_col Name der Latitude-Spalte.
#' @param lon_col Name der Longitude-Spalte.
#' @return Erweiterter DataFrame.
#' @export
add_geology_to_df <- function(df, geology_path, lat_col = "Lat", lon_col = "Lon") {
  query_engine <- GeoSoilQuery$new(geology_path)
  query_engine$query_batch(df, lat_col, lon_col)
}
