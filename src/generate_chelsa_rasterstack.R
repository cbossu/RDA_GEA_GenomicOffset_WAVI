#library(raster)
library(sf)
library(terra)
library(openxlsx)
library(tidyverse)
#library(geodata)

#Extract bioclim rasters for CHELSA 2.0
# Base URL for CHELSA bioclim data
base_url <- "https://os.unil.cloud.switch.ch/chelsa02/chelsa/global/bioclim/"

# Loop through bio1 to bio19
#for (i in 1:19) {
#  cat("Downloading bio", i, "...\n")
  
  # Format bio number with leading zero (01, 02, etc.)
#  bio_num <- sprintf("%02d", i)
  
  # Construct URL
#  bio_url <- paste0("/vsicurl/", base_url, "bio", bio_num, "/1981-2010/CHELSA_bio", bio_num, "_1981-2010_V.2.1.tif")
  
  # Load raster
#  bio_list[[i]] <- rast(bio_url)
#}

# Stack all bio variables
#bio_stack <- rast(bio_list)
bio_cols <- paste0("bio", sprintf("%02d", 1:19))
#names(bio_stack) <- bio_cols

# 2. Define the Extent for North America (US and Canada)
# WGS84 coordinates: xmin, xmax, ymin, ymax
# Roughly covering Canada and USA
na_extent <- ext(-170, -50, 0, 85)

# 3. Crop the global data to the North American region
#bioclim <- terra::crop(bio_stack, na_extent)

# 4. (Optional) Visualize
#plot(bioclim[[3]], main="Annual Mean Temperature - North America")

# 5. Save the merged/cropped stack
#terra::writeRaster(bioclim, "CHELSA_NorthAmerica_Bioclim19.tif", overwrite=TRUE)
bioclim<-rast("~/Desktop/WAVI/GEA/CHELSA_NorthAmerica_Bioclim19.tif")
plot(bioclim[[3]], main="Annual Mean Temperature - North America")

##Load srtm raster
elevation <- rast("~/Downloads/elevation.tif")
#Project on the correct crs
elevation_proj <- project(elevation, "EPSG:4326")  
##Load treecover, surface moisture=qscat
qscat <- rast("~/Dropbox/BGP/rasters/other/qscat.tif")
#tree <- rast("~/Dropbox/BGP/rasters/other/tree.tif")
tree <- terra::rast("~/Downloads/tree_canopy_capacity_future/tcc_current_climate.tif")
tree_proj <- project(tree, "EPSG:4326")  

tree_fut585 <- terra::rast("~/Downloads/tree_canopy_capacity_future/tcc_ACCESS-CM2_ssp585_2081-2100.tif")
tree_fut585_proj <- project(tree_fut585, "EPSG:4326")  

ext(elevation_proj)
ext(qscat)
ext(tree_proj)
ext(tree_fut585_proj)
res(elevation_proj)
res(qscat)
res(tree_proj)
crs(elevation_proj)
crs(qscat)
crs(tree_proj)

elev_proj_matched <- resample(elevation_proj,qscat, method = "bilinear")
tree_proj_matched <- resample(tree_proj,qscat, method = "bilinear")
tree_fut_proj_matched <- resample(tree_fut585_proj,qscat, method = "bilinear")

##Combine rasters into one stack
srtmstack<-c(elev_proj_matched,  qscat, tree_proj_matched)
names(srtmstack) <- c("elev", "qscat", "tree")

srtmstack_fut<-c(elev_proj_matched,  qscat, tree_fut_proj_matched)
names(srtmstack_fut) <- c("elev", "qscat", "tree")

##Load bioclim rasters for future
##Load ssp126 raster
# Loop through bio1 to bio19
#for (i in 1:19) {
#  cat("Downloading bio", i, "...\n")
  
  # Format bio number with leading zero (01, 02, etc.)
#  bio_num <- sprintf("%02d", i)
  
  # Construct URL
#  bio_url <- paste0("/vsicurl/", base_url, "bio", bio_num, "/2071-2100/GFDL-ESM4/ssp370/CHELSA_gfdl-esm4_ssp370_bio", bio_num, "_2071-2100_V.2.1.tif")
  
  # Load raster
#  bio_list[[i]] <- rast(bio_url)
#}

# Stack all bio variables
#ssp370 <- rast(bio_list)
#bio_cols <- paste0("bio", sprintf("%02d", 1:19))
#names(ssp370) <- bio_cols

# 2. Define the Extent for North America (US and Canada)
# WGS84 coordinates: xmin, xmax, ymin, ymax
# Roughly covering Canada and USA
na_extent <- ext(-170, -50, 0, 85)

# 3. Crop the global data to the North American region
#ssp370_na <- terra::crop(ssp370, na_extent)
#plot(ssp370_na[[3]], main="Bio03 - North America")

# 5. Save the merged/cropped stack
#terra::writeRaster(ssp370_na, "CHELSA_bioc_NorthAmerica_GFDL-ESM4_ssp370_2071-2100.tif", overwrite=TRUE)
#ssp370<-ssp370_na

ssp370<-rast("~/Desktop/WAVI/GEA/CHELSA_bioc_NorthAmerica_GFDL-ESM4_ssp370_2071-2100.tif")
plot(ssp370[[3]], main="Bio03 - North America")

##Load ssp585 raster
#for (i in 1:19) {
#  cat("Downloading bio", i, "...\n")
  
  # Format bio number with leading zero (01, 02, etc.)
#  bio_num <- sprintf("%02d", i)
  
  # Construct URL
#  bio_url <- paste0("/vsicurl/", base_url, "bio", bio_num, "/2071-2100/UKESM1-0-LL/ssp585/CHELSA_ukesm1-0-ll_ssp585_bio", bio_num, "_2071-2100_V.2.1.tif")
  
  # Load raster
 # bio_list[[i]] <- rast(bio_url)
#}

# Stack all bio variables
#ssp585 <- rast(bio_list)
#bio_cols <- paste0("bio", sprintf("%02d", 1:19))
#names(ssp585) <- bio_cols

# 2. Define the Extent for North America (US and Canada)
# WGS84 coordinates: xmin, xmax, ymin, ymax
# Roughly covering Canada and USA
na_extent <- ext(-170, -50, 0, 85)

# 3. Crop the global data to the North American region
#ssp585_na <- terra::crop(ssp585, na_extent)

# 5. Save the merged/cropped stack
#terra::writeRaster(ssp585_na, "CHELSA_bioc_NorthAmerica_UKESM1-0-LL_ssp585_2071-2100.tif", overwrite=TRUE)
#ssp585<-ssp585_na
ssp585 <- rast("~/Desktop/WAVI/GEA/CHELSA_bioc_NorthAmerica_UKESM1-0-LL_ssp585_2071-2100.tif")
bio_cols <- paste0("bio", sprintf("%02d", 1:19))
names(ssp585) <- bio_cols

waviSampled <- read_csv("input/WAVI249.GEA.sample_table.csv") %>% rename(long=longitude,lat=latitude)
waviSampled.xy.matrix <- as.matrix(waviSampled[,c("long","lat")])
waviSampled.xy<-st_as_sf(waviSampled, coords = c('long','lat')) %>% st_set_crs(4326) %>% sf::st_transform(crs = 4326)

waviSampled %>% mutate(Year=year(CollectionDate)) %>% dplyr::select(Year) %>% unique() %>% arrange(Year) %>% print(n=24)
##Extract current variables for sampled locations
waviBioClim <- raster::extract(bioclim,  waviSampled.xy)
waviSrtm <- raster::extract(srtmstack,  waviSampled.xy)
waviSrtm_fut <- raster::extract(srtmstack_fut,  waviSampled.xy)

## tree had NAs when extracting from just lat/long, so use buffer to extract mean tree cover capacity
library(sf)
coords_all <- st_as_sf(waviSampled, coords = c("long", "lat"), crs = 4326)
if (st_crs(coords_all) != st_crs(srtmstack)) {
  coords_all <- st_transform(coords_all, crs = st_crs(srtmstack))
}
crs(srtmstack) == crs(coords_all)


coords_all <- vect(coords_all) # must be spat vector for buffer function.
buffers_all <- terra::buffer(coords_all, width = 750) # radius is in meters

plot(srtmstack[[3]])
plot(buffers_all, add = TRUE, border = "red")

# count non-NA pixels per buffer
# count of non-NA pixels per buffer
n_valid <- terra::extract(srtmstack, buffers_all, fun = function(x, ...) sum(!is.na(x)))

# count of total pixels per buffer (valid + NA)
n_total <- terra::extract(srtmstack, buffers_all, fun = function(x, ...) length(x))

summary_df <- data.frame(
  ID = n_valid$ID,
  n_valid = n_valid$tree,
  n_total = n_total$tree
)
summary_df$pct_valid <- summary_df$n_valid / summary_df$n_total * 100

# how many buffers are FULLY NA (0 valid pixels)?
sum(summary_df$n_valid == 0)

# how many are PARTIALLY NA (some but not all valid)?
sum(summary_df$n_valid > 0 & summary_df$n_valid < summary_df$n_total)

# how many are fully valid?
sum(summary_df$n_valid == summary_df$n_total)

# look at the worst offenders
summary_df %>% filter(n_valid == 0)
summary_df %>% filter(n_valid > 0 & n_valid < n_total)
srtmstack_buff750 <- terra::extract(srtmstack, buffers_all, fun = mean, na.rm = TRUE) %>% dplyr::select(tree)

##Link data
waviEnv_bufftree<- data.frame(waviSampled[, c("long","lat")], waviBioClim, waviSrtm,srtmstack_buff750)
bio_cols <- paste0("bio", sprintf("%02d", 1:19))
colnames(waviEnv_bufftree) <- c("Long", "Lat", bio_cols,"elev","qscat","tree")

colSums(is.na(waviEnv_bufftree))

##Get breeding range for WAVI
wavi_breed <- st_read("~/Dropbox/BGP/WAVI/maps/warvir_range_2022/warvir_range_2022.gpkg") %>% dplyr::filter(season=="breeding")
sf::sf_use_s2(FALSE)

#breeding_merged <- breeding |>
#  dplyr::group_by(species_code) |>
#  dplyr::summarise() 
#rofi_st <- st_make_valid(breeding_merged)
wavi <- st_as_sf(wavi_breed)
class(wavi)
class(wavi_breed)
wavi_vect <- terra::vect(wavi)

##Limit variables to JUST the breeding range of Canada Warbler
bioclim_crop=crop(bioclim,wavi_breed)
bioclim_wavi=mask(bioclim_crop,wavi_breed)
#plot(bioclim_wavi)
srtmstack_crop=crop(srtmstack,wavi_breed)
srtmstack_wavi=mask(srtmstack_crop,wavi_breed)
srtmstack_fut_crop=crop(srtmstack_fut,wavi_breed)
srtmstack_fut_wavi=mask(srtmstack_fut_crop,wavi_breed)

#plot(srtmstack_cawa)
envVars <- c(bioclim_wavi, srtmstack_wavi)

##Limit variables to JUST the breeding range of Rosy-Finch complex, fill in NAs using nearest pixel
envVars_proj <- terra::project(envVars, crs(waviSampled.xy)) 
bioclim_wavi <- mask(envVars_proj,wavi)
env_pres_fill <- terra::approximate(bioclim_wavi, method="constant")
env_pres_fill <- mask(env_pres_fill, wavi)

##Future vars
##Uses current vars for elev, tree, qscat, and ndvi b/c no great predictive rasters for those

##Future vars
## SSP370-
ssp370_crop=crop(ssp370,wavi_breed)
ssp370_wavi=mask(ssp370_crop,wavi_breed)
#plot(ssp370_wavi)
#future370 <- c(ssp370_wavi, srtmstack_wavi)

ssp370plus <- c(ssp370_wavi, srtmstack_fut_wavi)
ssp370_proj <- terra::project(ssp370plus, crs(waviSampled.xy)) #make sure raster has same CRS as sampled data
ssp370_wavi <- mask(ssp370_proj,wavi) #only mask to species range
future370 <- terra::approximate(ssp370_wavi, method = "constant") #fill in NA
future370 <- mask(future370, wavi) #mask again to species range (only NAs outside the species range)

## SSP585 
ssp585_crop=crop(ssp585,wavi_breed)
ssp585_wavi=mask(ssp585_crop,wavi_breed)
ssp585plus <- c(ssp585_wavi, srtmstack_fut_wavi)
ssp585_proj <- terra::project(ssp585plus, crs(waviSampled.xy))
ssp585_wavi <- mask(ssp585_proj,wavi)
future585 <- terra::approximate(ssp585_wavi, method = "constant")
future585 <- mask(future585, wavi)

rm(list= ls()[!(ls() %in% c('envVars', 'ssp245', 'ssp585', 'range', 'wavi','wavi_vect','waviSampled', 'waviSampled.xy','envVars_proj','env_pres_fill','ssp370_proj','future370','ssp585_proj','future585'))])


##SSP585
#ssp585_crop=crop(ssp585,wavi_breed)
#ssp585_wavi=mask(ssp585_crop,wavi_breed)
#plot(ssp585_cawa)
#future585 <- c(ssp585_wavi, srtmstack_wavi)

##remove individual rasters
#rm(list= ls()[!(ls() %in% c('envVars', 'future370', 'future585','wavi'))])
