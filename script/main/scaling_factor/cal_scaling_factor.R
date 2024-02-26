#!/usr/bin/env Rscript
library(R.utils,warn.conflicts = FALSE)

read.spikeIn <- function(path) {
  f <- read.table(path)
  if (length(f) ==1) {
    return(as.numeric(f))
  }
  else{ stop( "invalid spike-in file - only one numeric value is accpetable ") }
}

cal.scaling.factor <- function(seq.depth, constant=1) {
  #S = C / (fragments mapped to E. coli genome)
  # add 1 pseudo fragment to avoid inf ratio
  scaling.factor <- constant/(seq.depth+1)
  return(scaling.factor)
}

main <- function(){

  #args0 <- base::commandArgs()
  args <- commandArgs(asValues=TRUE)
  #stopifnot(all.equal(args, args0, check.attributes=FALSE))
  if (length(args) == 1 ) {
    stop(" Only two argument are accepted (--spike_in_path --out_path)", call.=FALSE)
  } 
  spikeIn.path <- args[["spike_in_path"]]
  out.path <- args[["out_path"]]
  print(out.path)
  seq.depth <- read.spikeIn(spikeIn.path)
  scaling.factor <- cal.scaling.factor(seq.depth,constant=10000)
  write.table(scaling.factor,file=out.path,row.names=F,col.names = F )

}

main()
