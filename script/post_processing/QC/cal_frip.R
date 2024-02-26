#!/usr/bin/env Rscript

library(R.utils,warn.conflicts = FALSE)
library(rtracklayer,warn.conflicts = FALSE)
library(dplyr)
library(chromVAR)

load.peak <- function(peak.path){
  # loading bam and processing bam and   
  peak.tbl <- read.table( peak.path, header = FALSE, fill = TRUE)
  peak.gr <- GRanges(seqnames = peak.tbl$V1, IRanges(start = peak.tbl$V2, end = peak.tbl$V3), strand = "*")
  return(peak.gr)
}

get.frip <- function(bam.path,peak.gr){
  fragment_counts <- getCounts(bam.path, peak.gr, paired = TRUE, by_rg = FALSE, format = "bam")
  inPeakN <- counts(fragment_counts)[,1] %>% sum
  #based on the cut&tag tourial - total # of read should be used but chronVar only yield half the reads 
  frip <- inPeakN / ( fragment_counts@colData$depth *2 )
  return(frip)
}

main <- function(){

#args0 <- R.utils::commandArgs()
args <- R.utils::commandArgs(asValues=TRUE)
#stopifnot(all.equal(args, args0, check.attributes=FALSE))

if (length(args) < 2 ) {
  stop("Two arguments must be supplied (--bam and --peak).n", call.=FALSE)
} 

bam.path <- args[["bam"]]
peak.path <- args[["peak"]]
#print(peak.path)
peak.gr <- load.peak(peak.path)
frip.score <- get.frip(bam.path,peak.gr)

tryCatch({ out.path <- args[["out"]]
print(out.path)
write(frip.score,out.path)}, error= function(e){
    print(frip.score)
      })
}

main()
  

