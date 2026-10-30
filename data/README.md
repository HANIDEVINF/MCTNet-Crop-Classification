# Data

CSV files are intentionally **not committed** (≈290 MB in total). Two ways to get them:

1. **Regenerate** with `notebooks/01_extract_sentinel2_gee.ipynb` (Sentinel-2 time series + CDL labels) and `notebooks/02_enrich_covariates_gee.ipynb` (ERA5 climate, soil, topography). Requires a Google Earth Engine account and your own Cloud project ID.
2. **Download the release archive** `mctnet-datasets-2021.zip` from this repository's *Releases* page (if published).

Expected files:

| File | Used by |
|---|---|
| `MCTNet_Arkansas_2021_fixed.csv`, `MCTNet_California_2021_fixed.csv` | Part 1 (base Sentinel-2) |
| `MCTNet_Arkansas_2021_enriched_fixed.csv`, `MCTNet_California_2021_enriched_fixed.csv` | Parts 2–3 (Sentinel-2 + covariates) |

Layout: one row per pixel, columns `<Band>_t01 … <Band>_t36` (10 bands), `valid_t01 … valid_t36` (cloud mask), a `label`, and coordinates. Enriched files add 108 climate columns and 5 static covariates.
