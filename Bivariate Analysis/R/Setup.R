library(cansim)
library(cancensus)

#Get data

#For CANSIM tables: looking for ones with GEOUID


options(cansim.cache_path="data/census_cache")
options(cancensus.cache_path="data/census_cache")
list_cansim_tables()

list_census_datasets(use_cache = FALSE, quiet = FALSE)
list_census_regions("CA16", use_cache = FALSE, quiet = TRUE)
list_census_vectors("CA16", use_cache = TRUE, quiet = TRUE)
lister <- list_census_vectors("CA16", use_cache = TRUE, quiet = TRUE)
lister[4001:6623,]

# Possible variables:

# v_CA16_497 Total - Lone-parent census families in private households - 100% data

# v_CA16_512	Total	Total - Knowledge of official languages for the total population excluding institutional residents 
# v_CA16_515	Total	English only	Number	v_CA16_512	Additive	CA 2016 Census
# v_CA16_518	Total	French only	Number	v_CA16_512	Additive	CA 2016 Census
# v_CA16_521	Total	English and French	Number	v_CA16_512	Additive	CA 2016 Census; 
# v_CA16_524	Total	Neither English nor French
# v_CA16_3408 Total Non-immigrant
# v_CA16_3411 Total immigrant