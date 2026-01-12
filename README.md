# GeoSoilQuery

*English Version below* 

GeoSoilQuery ist ein R-Paket zur schnellen räumlichen Abfrage geologischer Parameter
auf Basis des IGME5000-Datensatzes. Es kapselt das Laden und räumliche Joinen großer
Geodatensätze und stellt eine einfache API für Punkt- und Batch-Abfragen bereit.

Das Paket richtet sich an Nutzer, die geologische Kontextinformationen effizient
in räumliche Analysen integrieren möchten.



## Installation

### Aktuell (GitHub)

```r
install.packages("remotes")
remotes::install_github("philippaugustmuenker/GeoSoilQuery")
```


### Daten

Aus Lizenz- und Größen­gründen sind die IGME5000-Geodaten nicht Teil dieses Repositories.

### Daten anfragen

Wenn du die Daten verwenden möchtest, schreibe bitte eine kurze Mail an:

[philippaugustmuenker@gmail.com](mailto:philippaugustmuenker@gmail.com)

Du erhältst dann einen privaten Download-Link.

Nach dem Download entpacke den Ordner z.B. nach:

`~/data/IGME5000`

## Beispiel


### Datenpfad setzen

```r
library(GeoSoilQuery)

geology_path <- "~/data/IGME5000/europe/data/IGME5000_europeEPSG3034shp_geology_poly_v01.shp"

```

### Einzelpunkt-Abfrage


```r
geo <- GeoSoilQuery$new(geology_path)

geo$query_geology(lat = 50.9375, lon = 6.9603)
```

### Batch-Abfrage


```r
df <- data.frame(
  Site = c("Koeln", "Berlin"),
  Lat  = c(50.9375, 52.5200),
  Lon  = c(6.9603, 13.4050)
)

geo$query_batch(df, lat_col = "Lat", lon_col = "Lon")

```
### Cache 


```r
geo$cache_info()
geo$clear_cache()
```

### Hinweise

* Die Koordinaten müssen im WGS84-Format (EPSG:4326) angegeben werden.
* Der Shapefile wird intern einmal geladen und transformiert.
* Ergebnisse können optional gecacht werden.

### Daten 
Die geologischen Daten stammen aus dem IGME5000-Projekt der EuroGeoSurveys.

Die Daten werden hier ausschließlich zu Demonstrations- und Analysezwecken verwendet.
Alle Rechte verbleiben bei den jeweiligen Urhebern.

[https://www.europe-geology.eu/de/project/igme-5000-3/](https://www.europe-geology.eu/de/project/igme-5000-3/)

### Lizenz
Dieses Paket steht unter der MIT-Lizenz (siehe LICENSE).







# GeoSoilQuery

GeoSoilQuery is an R package for fast spatial queries of geological parameters
based on the IGME5000 dataset. It encapsulates loading and spatial joining of large
geological datasets and provides a simple API for point-based and batch-based queries.

The package is intended for users who want to efficiently integrate geological
context information into spatial analyses.



## Installation

### Current (GitHub)

```r
install.packages("remotes")
remotes::install_github("philippaugustmuenker/GeoSoilQuery")
```


## Data

Due to licensing and file size restrictions, the IGME5000 geodata are **not included**
in this repository.



### Requesting the data

If you would like to use the data, please send a short email to:

📧 [philippaugustmuenker@gmail.com](mailto:philippaugustmuenker@gmail.com)

You will then receive a private download link.

After downloading, extract the folder for example to:

`~/data/IGME5000`



## Example

### Set data path

```r
library(GeoSoilQuery)

geology_path <- "~/data/IGME5000/europe/data/IGME5000_europeEPSG3034shp_geology_poly_v01.shp"
```



### Single point query

```r
geo <- GeoSoilQuery$new(geology_path)

geo$query_geology(lat = 50.9375, lon = 6.9603)
```


### Batch query

```r
df <- data.frame(
  Site = c("Koeln", "Berlin"),
  Lat  = c(50.9375, 52.5200),
  Lon  = c(6.9603, 13.4050)
)

geo$query_batch(df, lat_col = "Lat", lon_col = "Lon")
```



### Cache

```r
geo$cache_info()
geo$clear_cache()
```



## Notes

- Coordinates must be provided in WGS84 format (EPSG:4326).
- The shapefile is loaded and transformed internally only once.
- Results can optionally be cached to improve performance.



## Data source

The geological data originate from the **IGME5000 project** of EuroGeoSurveys.

The data are used here exclusively for demonstration and analytical purposes.
All rights remain with the respective data providers.

https://www.europe-geology.eu/project/igme-5000-3/



## License

This package is released under the MIT License (see LICENSE).







