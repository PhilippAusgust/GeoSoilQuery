# GeoSoilQuery

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-%3E%3D%204.0-blue)](https://www.r-project.org/)

Ein R-Paket zur effizienten räumlichen Abfrage geologischer Parameter auf Basis des IGME5000-Datensatzes.

---

## Überblick

**GeoSoilQuery** ermöglicht die schnelle und unkomplizierte räumliche Abfrage geologischer Parameter aus dem IGME5000-Datensatz von EuroGeoSurveys. Das Paket kapselt das Laden und räumliche Joinen großer Geodatensätze und bietet eine intuitive API für Einzelpunkt- und Batch-Abfragen.

Das Paket richtet sich an Wissenschaftler und Analysten, die geologische Kontextinformationen effizient in ihre räumlichen Analysen integrieren möchten.

## Hauptfunktionen

- **Einzelpunkt-Abfragen**: Geologische Parameter für einzelne Koordinaten abrufen
- **Batch-Verarbeitung**: Mehrere Standorte gleichzeitig abfragen
- **Caching-Mechanismus**: Optimierte Performance durch optionales Caching
- **WGS84-Unterstützung**: Standardisierte Koordinateneingabe (EPSG:4326)
- **R6-Klassensystem**: Moderne objektorientierte Schnittstelle

## Installation

Das Paket kann direkt von GitHub installiert werden:

```r
# Installation von remotes (falls noch nicht vorhanden)
if (!require("remotes")) install.packages("remotes")

# Installation von GeoSoilQuery
remotes::install_github("PhilippAusgust/GeoSoilQuery")
```

### Systemvoraussetzungen

- R ≥ 4.0
- Erforderliche Pakete: `sf`, `R6`, `dplyr`

## Datenquelle

Die geologischen Daten stammen aus dem **IGME5000-Projekt** von EuroGeoSurveys, einer Initiative zur Harmonisierung geologischer Informationen in Europa.

**Wichtig**: Aus Lizenz- und Größengründen sind die IGME5000-Geodaten nicht Bestandteil dieses Repositories.

### Datenzugang

Für den Zugang zu den benötigten Geodaten wenden Sie sich bitte an:

📧 [philippaugustmuenker@gmail.com](mailto:philippaugustmuenker@gmail.com)

Sie erhalten anschließend einen privaten Download-Link. Nach dem Download entpacken Sie die Daten in ein geeignetes Verzeichnis, z.B.:

```
~/data/IGME5000/
```

Weitere Informationen zum IGME5000-Projekt:  
[https://www.europe-geology.eu/de/project/igme-5000-3/](https://www.europe-geology.eu/de/project/igme-5000-3/)

## IGME5000 Datenstruktur

Der IGME5000-Datensatz folgt einer hierarchischen Struktur mit verschiedenen Parameterebenen:

### Räumliche Ebene
```
├── geometry        Vektorgeometrie der geologischen Einheit (Polygon/Multipolygon)
├── area_id         Eindeutige numerische Flächen-ID für jedes Polygon
├── Shape_STAr      Berechneter Flächeninhalt des Polygons
└── Shape_STLe      Berechnete Umfangslänge des Polygons
```

### Geologische Klassifikation
```
├── GEO             Eindeutige geologische Einheiten-ID
├── MARIN           Klassifizierung: Marine (Offshore) oder Kontinental (Onshore)
│
├── Alter
│   ├── Portr_AGE   Kodierte Darstellung des geologischen Zeitalters (für Kartenfarbgebung)
│   ├── AgeName     Textuelle Bezeichnung des geologischen Zeitalters (z.B. "Ordovician")
│   ├── AgeOldest   Numerisches maximales Alter in Millionen Jahren (Ma)
│   └── AgeNewest   Numerisches minimales Alter in Millionen Jahren (Ma)
│
├── Lithologie/Petrographie
│   ├── Portr_Petr  Hauptklassifikation der Gesteinsart (Sediment, Magmatit, Metamorphit)
│   ├── Portr_Pe_1  Erste Detailebene (z.B. klastisch vs. karbonatisch)
│   ├── Portr_Pe_2  Zweite Detailebene (z.B. Korngröße, Zusammensetzung)
│   └── Portr_Pe_3  Dritte Detailebene (detaillierte mineralogische Eigenschaften)
│
├── Spezielle Eigenschaften
│   ├── Portr_META  Metamorphosegrad (z.B. niedrig-, mittel-, hochgradig)
│   ├── Portr_IGNE  Klassifikation magmatischer Gesteine (plutonisch, vulkanisch)
│   ├── Portr_MARI  Spezifische marine geologische Einheiten (ozeanische Kruste, Schelf)
│   └── Portr_IceO  Kennzeichnung von Eis- und Ozeangebieten
│
└── Kontextinformation
    ├── regName     Regionaler oder lokaler Formationsname (z.B. "Buntsandstein")
    └── genElement  Genetisches/tektonisches Element (z.B. Becken, Orogen, Kraton)
```

### Erläuterung der Parameter-Hierarchie

Die Datenstruktur ist so organisiert, dass:

1. **Räumliche Parameter** die geometrische Grundlage bilden
2. **Alter-Parameter** die zeitliche Einordnung ermöglichen (sowohl kategorisch als auch numerisch)
3. **Lithologie-Parameter** in drei Detaillierungsstufen die Gesteinstypen klassifizieren
4. **Spezielle Eigenschaften** zusätzliche petrologische Informationen liefern
5. **Kontextinformationen** regionale und tektonische Einbettung beschreiben

Diese hierarchische Organisation ermöglicht flexible Abfragen auf verschiedenen Detailebenen, von groben geologischen Überblicken bis zu spezifischen petrographischen Analysen.

## Verwendung

### Initialisierung

```r
library(GeoSoilQuery)

# Pfad zur IGME5000-Shapefile definieren
geology_path <- "~/data/IGME5000/europe/data/IGME5000_europeEPSG3034shp_geology_poly_v01.shp"

# GeoSoilQuery-Objekt erstellen
geo <- GeoSoilQuery$new(geology_path)
```

### Einzelpunkt-Abfrage

```r
# Geologische Parameter für Köln abfragen
result <- geo$query_geology(lat = 50.9375, lon = 6.9603)
print(result)
```

### Batch-Abfrage

```r
# Datensatz mit mehreren Standorten erstellen
sites <- data.frame(
  Grid = c(100, 101, 102, 103, 104, 105, 106, 107, 108, 109),
  Site = c("Köln", "Berlin", "München", "Hamburg", "Frankfurt", 
           "Stuttgart", "Düsseldorf", "Dortmund", "Essen", "Leipzig"),
  Lat  = c(50.9375, 52.5200, 48.1351, 53.5511, 50.1109,
           48.7758, 51.2277, 51.5136, 51.4556, 51.3397),
  Lon  = c(6.9603, 13.4050, 11.5820, 9.9937, 8.6821,
           9.1829, 6.7735, 7.4653, 7.0116, 12.3731)
)

# Batch-Abfrage durchführen
results <- geo$query_batch(sites, lat_col = "Lat", lon_col = "Lon")
print(results)
```

### Cache-Verwaltung

```r
# Cache-Informationen anzeigen
geo$cache_info()

# Cache leeren
geo$clear_cache()
```

## Beispielabfragen nach Parametern

### Abfrage nach Alter

```r
# Gesteine älter als 500 Millionen Jahre
old_rocks <- results[results$AgeOldest > 500, ]

# Ordovizische Gesteine
ordovician <- results[grepl("Ordovician", results$AgeName, ignore.case = TRUE), ]
```

### Abfrage nach Lithologie

```r
# Nur magmatische Gesteine
igneous <- results[!is.na(results$Portr_IGNE), ]

# Metamorphe Gesteine mit hohem Grad
high_meta <- results[!is.na(results$Portr_META), ]
```

### Abfrage nach regionalen Formationen

```r
# Deutsche regionale Formationen
german_formations <- results[!is.na(results$regName), ]
```

## Technische Hinweise

- **Koordinatensystem**: Alle Eingabekoordinaten müssen im WGS84-Format (EPSG:4326, Dezimalgrad) vorliegen
- **Datenverarbeitung**: Der Shapefile wird beim ersten Laden automatisch geladen und in das entsprechende Koordinatensystem transformiert
- **Performance**: Durch intelligentes Caching werden wiederholte Abfragen deutlich beschleunigt
- **Speicherbedarf**: Bei großen Datensätzen kann der Speicherbedarf signifikant sein
- **Maßstab**: IGME5000 hat einen Maßstab von 1:5.000.000, was eine starke Generalisierung bedeutet

## Zitation

Bei Verwendung dieses Pakets in wissenschaftlichen Publikationen bitten wir um Nennung sowohl des Pakets als auch der zugrunde liegenden IGME5000-Datenquelle.

```
Münker, P. A. (2025). GeoSoilQuery: Spatial Query Tool for Geological Parameters.
R package. https://github.com/PhilippAusgust/GeoSoilQuery

Asch, K. (2005). The 1:5 Million International Geological Map of Europe and 
Adjacent Areas - IGME 5000. BGR, Hannover. 
DOI: https://doi.org/10.25928/igme-5000
```

## Lizenz

Dieses Paket steht unter der MIT-Lizenz (siehe [LICENSE](LICENSE)).

**Hinweis zur Datennutzung**: Die IGME5000-Daten unterliegen eigenen Lizenzbedingungen. Alle Rechte an den geologischen Daten verbleiben bei EuroGeoSurveys und den jeweiligen nationalen geologischen Diensten. Die Daten werden in diesem Paket ausschließlich zu wissenschaftlichen und analytischen Zwecken verwendet.

## Kontakt und Beiträge

**Autor**: Philipp August Münker  
**E-Mail**: [philippaugustmuenker@gmail.com](mailto:philippaugustmuenker@gmail.com)  
**Repository**: [https://github.com/PhilippAusgust/GeoSoilQuery](https://github.com/PhilippAusgust/GeoSoilQuery)

Beiträge, Fehlerberichte und Feature-Anfragen sind herzlich willkommen. Bitte nutzen Sie dazu die Issue-Tracking-Funktion auf GitHub.

---

# GeoSoilQuery

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-%3E%3D%204.0-blue)](https://www.r-project.org/)

An R package for efficient spatial queries of geological parameters based on the IGME5000 dataset.

---

## Overview

**GeoSoilQuery** provides fast and straightforward spatial queries of geological parameters from the EuroGeoSurveys IGME5000 dataset. The package encapsulates loading and spatial joining of large geodatasets, offering an intuitive API for single-point and batch queries.

The package is designed for researchers and analysts who need to efficiently integrate geological context information into their spatial analyses.

## Key Features

- **Single-point queries**: Retrieve geological parameters for individual coordinates
- **Batch processing**: Query multiple locations simultaneously
- **Caching mechanism**: Optimized performance through optional caching
- **WGS84 support**: Standardized coordinate input (EPSG:4326)
- **R6 class system**: Modern object-oriented interface

## Installation

The package can be installed directly from GitHub:

```r
# Install remotes (if not already installed)
if (!require("remotes")) install.packages("remotes")

# Install GeoSoilQuery
remotes::install_github("PhilippAusgust/GeoSoilQuery")
```

### System Requirements

- R ≥ 4.0
- Required packages: `sf`, `R6`, `dplyr`

## Data Source

The geological data originate from the **IGME5000 project** by EuroGeoSurveys, an initiative to harmonize geological information across Europe.

**Important**: Due to licensing and file size constraints, the IGME5000 geodata are not included in this repository.

### Data Access

To obtain access to the required geodata, please contact:

📧 [philippaugustmuenker@gmail.com](mailto:philippaugustmuenker@gmail.com)

You will receive a private download link. After downloading, extract the data to a suitable directory, e.g.:

```
~/data/IGME5000/
```

Further information about the IGME5000 project:  
[https://www.europe-geology.eu/project/igme-5000-3/](https://www.europe-geology.eu/project/igme-5000-3/)

## IGME5000 Data Structure

The IGME5000 dataset follows a hierarchical structure with different parameter levels:

### Spatial Level
```
├── geometry        Vector geometry of the geological unit (Polygon/Multipolygon)
├── area_id         Unique numeric area ID for each polygon
├── Shape_STAr      Calculated area of the polygon
└── Shape_STLe      Calculated perimeter length of the polygon
```

### Geological Classification
```
├── GEO             Unique geological unit ID
├── MARIN           Classification: Marine (Offshore) or Continental (Onshore)
│
├── Age
│   ├── Portr_AGE   Coded representation of geological age (for map coloring)
│   ├── AgeName     Textual designation of geological age (e.g., "Ordovician")
│   ├── AgeOldest   Numerical maximum age in million years (Ma)
│   └── AgeNewest   Numerical minimum age in million years (Ma)
│
├── Lithology/Petrography
│   ├── Portr_Petr  Main classification of rock type (sedimentary, igneous, metamorphic)
│   ├── Portr_Pe_1  First detail level (e.g., clastic vs. carbonate)
│   ├── Portr_Pe_2  Second detail level (e.g., grain size, composition)
│   └── Portr_Pe_3  Third detail level (detailed mineralogical properties)
│
├── Special Properties
│   ├── Portr_META  Metamorphic grade (e.g., low-, medium-, high-grade)
│   ├── Portr_IGNE  Classification of igneous rocks (plutonic, volcanic)
│   ├── Portr_MARI  Specific marine geological units (oceanic crust, shelf)
│   └── Portr_IceO  Designation of ice and ocean areas
│
└── Context Information
    ├── regName     Regional or local formation name (e.g., "Old Red Sandstone")
    └── genElement  Genetic/tectonic element (e.g., basin, orogen, craton)
```

### Parameter Hierarchy Explanation

The data structure is organized such that:

1. **Spatial parameters** form the geometric foundation
2. **Age parameters** enable temporal classification (both categorical and numerical)
3. **Lithology parameters** classify rock types in three levels of detail
4. **Special properties** provide additional petrological information
5. **Context information** describes regional and tectonic setting

This hierarchical organization enables flexible queries at different levels of detail, from broad geological overviews to specific petrographic analyses.

## Usage

### Initialization

```r
library(GeoSoilQuery)

# Define path to IGME5000 shapefile
geology_path <- "~/data/IGME5000/europe/data/IGME5000_europeEPSG3034shp_geology_poly_v01.shp"

# Create GeoSoilQuery object
geo <- GeoSoilQuery$new(geology_path)
```

### Single-point Query

```r
# Query geological parameters for Cologne
result <- geo$query_geology(lat = 50.9375, lon = 6.9603)
print(result)
```

### Batch Query

```r
# Create dataset with multiple sites
sites <- data.frame(
  Grid = c(100, 101, 102, 103, 104, 105, 106, 107, 108, 109),
  Site = c("Cologne", "Berlin", "Munich", "Hamburg", "Frankfurt", 
           "Stuttgart", "Düsseldorf", "Dortmund", "Essen", "Leipzig"),
  Lat  = c(50.9375, 52.5200, 48.1351, 53.5511, 50.1109,
           48.7758, 51.2277, 51.5136, 51.4556, 51.3397),
  Lon  = c(6.9603, 13.4050, 11.5820, 9.9937, 8.6821,
           9.1829, 6.7735, 7.4653, 7.0116, 12.3731)
)

# Perform batch query
results <- geo$query_batch(sites, lat_col = "Lat", lon_col = "Lon")
print(results)
```

### Cache Management

```r
# Display cache information
geo$cache_info()

# Clear cache
geo$clear_cache()
```

## Example Queries by Parameter

### Query by Age

```r
# Rocks older than 500 million years
old_rocks <- results[results$AgeOldest > 500, ]

# Ordovician rocks
ordovician <- results[grepl("Ordovician", results$AgeName, ignore.case = TRUE), ]
```

### Query by Lithology

```r
# Igneous rocks only
igneous <- results[!is.na(results$Portr_IGNE), ]

# High-grade metamorphic rocks
high_meta <- results[!is.na(results$Portr_META), ]
```

### Query by Regional Formations

```r
# Regional formations
regional_formations <- results[!is.na(results$regName), ]
```

## Technical Notes

- **Coordinate system**: All input coordinates must be in WGS84 format (EPSG:4326, decimal degrees)
- **Data processing**: The shapefile is automatically loaded and transformed to the appropriate coordinate system upon first use
- **Performance**: Intelligent caching significantly accelerates repeated queries
- **Memory requirements**: Memory consumption may be substantial for large datasets
- **Scale**: IGME5000 has a scale of 1:5,000,000, which means strong generalization

## Citation

When using this package in scientific publications, please cite both the package and the underlying IGME5000 data source.

```
Münker, P. A. (2025). GeoSoilQuery: Spatial Query Tool for Geological Parameters.
R package. https://github.com/PhilippAusgust/GeoSoilQuery

Asch, K. (2005). The 1:5 Million International Geological Map of Europe and 
Adjacent Areas - IGME 5000. BGR, Hannover. 
DOI: https://doi.org/10.25928/igme-5000
```

## License

This package is released under the MIT License (see [LICENSE](LICENSE)).

**Data usage notice**: The IGME5000 data are subject to their own licensing terms. All rights to the geological data remain with EuroGeoSurveys and the respective national geological surveys. The data are used in this package exclusively for scientific and analytical purposes.

## Contact and Contributions

**Author**: Philipp August Münker  
**Email**: [philippaugustmuenker@gmail.com](mailto:philippaugustmuenker@gmail.com)  
**Repository**: [https://github.com/PhilippAusgust/GeoSoilQuery](https://github.com/PhilippAusgust/GeoSoilQuery)

Contributions, bug reports, and feature requests are welcome. Please use the issue tracking feature on GitHub.

---
