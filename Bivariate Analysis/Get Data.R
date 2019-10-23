library(cansim)
library(cancensus)

#Get data

#For CANSIM tables: looking for ones with GEOUID


options(cansim.cache_path="data/census_cache")
list_cansim_tables()

list_census_datasets(use_cache = FALSE, quiet = FALSE)
list_census_regions("CA16", use_cache = FALSE, quiet = TRUE)
list_census_vectors("CA16", use_cache = TRUE, quiet = TRUE)
lister <- list_census_vectors("CA16", use_cache = TRUE, quiet = TRUE)
lister[4001:6623,]
