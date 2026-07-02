genomic_offset <- function(RDA, K, env_pres, env_fut,
                           range = NULL,
                           method = "loadings",
                           scale_env,
                           center_env){
  
  library(terra)
  
  # -----------------------------
  # Mask rasters if range supplied
  # -----------------------------
  if(!is.null(range)){
    env_pres_mask <- mask(crop(env_pres, range), range)
    env_fut_mask  <- mask(crop(env_fut, range), range)
  } else {
    env_pres_mask <- env_pres
    env_fut_mask  <- env_fut
  }
  
  # -----------------------------
  # Fill internal NA holes
  # -----------------------------
  env_pres_fill <- approximate(env_pres_mask, method="constant")
  env_fut_fill  <- approximate(env_fut_mask, method="constant")
  
  if(!is.null(range)){
    env_pres_fill <- mask(env_pres_fill, range)
    env_fut_fill  <- mask(env_fut_fill, range)
  }
  
  # -----------------------------
  # Convert rasters to dataframe
  # -----------------------------
  var_env_proj_pres1 <- as.data.frame(
    terra::as.points(env_pres_fill[[row.names(RDA$CCA$biplot)]],
                     values=TRUE, na.rm=TRUE), geom="XY")
  
  var_env_proj_pres2 <- var_env_proj_pres1 |>
    dplyr::select(x,y,everything())
  
  var_env_proj_pres <- as.data.frame(
    scale(var_env_proj_pres2[,-c(1,2)],
          center_env[row.names(RDA$CCA$biplot)],
          scale_env[row.names(RDA$CCA$biplot)]))
  
  var_env_proj_fut1 <- as.data.frame(
    terra::as.points(env_fut_fill[[row.names(RDA$CCA$biplot)]],
                     values=TRUE, na.rm=TRUE), geom="XY")
  
  var_env_proj_fut2 <- var_env_proj_fut1 |>
    dplyr::select(x,y,everything())
  
  var_env_proj_fut <- as.data.frame(
    scale(var_env_proj_fut2[,-c(1,2)],
          center_env[row.names(RDA$CCA$biplot)],
          scale_env[row.names(RDA$CCA$biplot)]))
  
  # -----------------------------
  # Projection using loadings
  # -----------------------------
  Proj_pres <- list()
  Proj_fut  <- list()
  Proj_offset <- list()
  
  if(method == "loadings"){
    
    template <- env_pres_fill[[1]]
    idx <- which(!is.na(values(template)))
    
    for(i in 1:K){
      
      # Current
      ras_pres <- template
      vals_pres <- apply(
        var_env_proj_pres[,names(RDA$CCA$biplot[,i])],
        1,
        function(x) sum(x * RDA$CCA$biplot[,i])
      )
      
      ras_pres[] <- NA
      ras_pres[!is.na(values(template))] <- vals_pres
      names(ras_pres) <- paste0("RDA_pres_",i)
      Proj_pres[[i]] <- ras_pres
      
      # Future
      ras_fut <- template
      vals_fut <- apply(
        var_env_proj_fut[,names(RDA$CCA$biplot[,i])],
        1,
        function(x) sum(x * RDA$CCA$biplot[,i])
      )
      
      ras_fut[] <- NA
      ras_fut[!is.na(values(template))] <- vals_fut
      names(ras_fut) <- paste0("RDA_fut_",i)
      
      ras_fut <- resample(ras_fut, ras_pres, method="bilinear")
      Proj_fut[[i]] <- ras_fut
      
      # Offset
      Proj_offset[[i]] <- abs(ras_pres - ras_fut)
    }
  }
  
  # -----------------------------
  # Weights from eigenvalues
  # -----------------------------
  weights <- RDA$CCA$eig / sum(RDA$CCA$eig)
  
  # -----------------------------
  # Weighted adaptive indices
  # -----------------------------
  pres_vals <- sapply(1:K, function(x)
    terra::values(Proj_pres[[x]]) * weights[x])
  
  fut_vals <- sapply(1:K, function(x)
    terra::values(Proj_fut[[x]]) * weights[x])
  
  # Euclidean distance
  offset_vals <- sqrt(rowSums((pres_vals - fut_vals)^2))
  
  ras <- Proj_pres[[1]]
  ras[] <- offset_vals
  names(ras) <- "Global_offset"
  
  Proj_offset_global <- ras
  
  return(list(
    Proj_pres = Proj_pres,
    Proj_fut = Proj_fut,
    Proj_offset = Proj_offset,
    Proj_offset_global = Proj_offset_global,
    weights = weights[1:K]
  ))
}
