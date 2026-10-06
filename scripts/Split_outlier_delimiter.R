##if each scaffold/chrom has the same number of "." delimiters (this is if it had 3)
cand_pos <- t(sapply(candidate_snps, function(x) {
  # split chrom vs position/allele
  parts <- str_split(x, fixed("."), n = 3)[[1]]
  
  if (length(parts) < 3) {
    cat("Problem SNP (no ':'):", x, "\n")
    return(c(CHROM = NA, POS = NA))
  }
  
  chrom <- paste(parts[1], parts[2], sep = ".")
  pos_allele <- parts[3]

  # extract numeric position before underscore
  pos <- suppressWarnings(as.integer(str_split(pos_allele, "_")[[1]][1]))
  
  if (is.na(pos)) {
    cat("Could not parse position for SNP:", x, "\n")
  }
  
  c(CHROM = chrom, POS = pos)
}))
