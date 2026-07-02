library(raster)
library(sp)
library(sf)
library(terra)
library(openxlsx)
library(sf)
library(tidyverse)
library(geodata)

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
##Load treecover, wind
qscat <- rast("~/Dropbox/BGP/rasters/other/qscat.tif")
tree <- rast("~/Dropbox/BGP/rasters/other/tree.tif")

ext(elevation_proj)
ext(qscat)
ext(tree)
res(elevation_proj)
res(qscat)
res(tree)
crs(elevation_proj)
crs(qscat)
crs(tree)

elev_proj_matched <- resample(elevation_proj,qscat, method = "bilinear")
##Combine rasters into one stack
srtmstack<-c(elev_proj_matched,  qscat, tree)
names(srtmstack) <- c("elev", "qscat", "tree")

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
ssp585 <- raster("~/Desktop/WAVI/GEA/CHELSA_bioc_NorthAmerica_UKESM1-0-LL_ssp585_2071-2100.tif")

##remove individual rasters
rm(list= ls()[!(ls() %in% c('srtmstack','bioclim', 'ssp370', 'ssp585'))])

waviSampled <- read_csv("input/WAVI249.GEA.sample_table.csv") %>% rename(long=longitude,lat=latitude)
waviSampled.xy <- as.matrix(waviSampled[,c("long","lat")])
waviSampled %>% mutate(Year=year(CollectionDate)) %>% dplyr::select(Year) %>% unique() %>% arrange(Year) %>% print(n=24)
##Extract current variables for sampled locations
waviBioClim <- raster::extract(bioclim,  waviSampled.xy)
waviSrtm <- raster::extract(srtmstack,  waviSampled.xy)

##Link data
waviEnv<- data.frame(waviSampled[, c("long","lat")], waviBioClim, waviSrtm)
bio_cols <- paste0("bio", sprintf("%02d", 1:19))
colnames(waviEnv) <- c("Long", "Lat", bio_cols,"elev","qscat","tree")

write.table(waviEnv,file="input/WAVI.249.Chelsa.elev_tree.txt",row.names=FALSE,quote=F,sep='\t')

##Get breeding range for CAWA
wavi_breed <- st_read("~/Dropbox/BGP/WAVI/maps/warvir_range_2022/warvir_range_2022.gpkg") %>% dplyr::filter(season=="breeding")

##Limit variables to JUST the breeding range of Canada Warbler
bioclim_crop=crop(bioclim,wavi_breed)
bioclim_wavi=mask(bioclim_crop,wavi_breed)
#plot(bioclim_wavi)
srtmstack_crop=crop(srtmstack,wavi_breed)
srtmstack_wavi=mask(srtmstack_crop,wavi_breed)
#plot(srtmstack_cawa)
envVars <- c(bioclim_wavi, srtmstack_wavi)

##Future vars
##Uses current vars for elev, tree, qscat, and ndvi b/c no great predictive rasters for those

##SSP126
ssp370_crop=crop(ssp370,wavi_breed)
ssp370_wavi=mask(ssp370_crop,wavi_breed)
#plot(ssp370_wavi)
future370 <- c(ssp370_wavi, srtmstack_wavi)

##SSP585
ssp585_crop=crop(ssp585,wavi_breed)
ssp585_wavi=mask(ssp585_crop,wavi_breed)
#plot(ssp585_cawa)
future585 <- c(ssp585_wavi, srtmstack_wavi)

##remove individual rasters
rm(list= ls()[!(ls() %in% c('envVars', 'future370', 'future585'))])
