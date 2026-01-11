# GeoSoilQuery

GeoSoilQuery ist ein R-Paket zur schnellen räumlichen Abfrage geologischer Parameter
auf Basis des IGME5000-Datensatzes. Es kapselt das Laden und räumliche Joinen großer
Geodatensätze und stellt eine einfache API für Punkt- und Batch-Abfragen bereit.

Das Paket richtet sich an Nutzer:innen, die geologische Kontextinformationen effizient
in räumliche Analysen integrieren möchten.

---

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

```{r}
library(GeoSoilQuery)

geology_path <- "~/data/IGME5000/europe/data/IGME5000_europeEPSG3034shp_geology_poly_v01.shp"

```

### Einzelpunkt-Abfrage


```{r}
geo <- GeoSoilQuery$new(geology_path)

geo$query_geology(lat = 50.9375, lon = 6.9603)
```

### Batch-Abfrage


```{r}
df <- data.frame(
  Site = c("Koeln", "Berlin"),
  Lat  = c(50.9375, 52.5200),
  Lon  = c(6.9603, 13.4050)
)

geo$query_batch(df, lat_col = "Lat", lon_col = "Lon")

```
### Cache 


```{r}
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

