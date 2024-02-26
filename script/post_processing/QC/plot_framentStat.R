#!/usr/bin/env Rscript

library(ggplot)
library(dplyr)


 parse.frag <- function(path,sample){
     frag.len <- read.table(path, header = FALSE) %>% mutate(fragLen = V1 %>% as.numeric, fragCount = V2 %>% as.numeric, Weight = as.numeric(V2)/sum(as.numeric(V2)), Sample = sample) 
 }

main <- function(){

#args0 <- R.utils::commandArgs()
args <- commandArgs(asValues=TRUE)
#stopifnot(all.equal(args, args0, check.attributes=FALSE))

if (length(args) < 3 ) {
  stop("Two arguments must be supplied (--fragmentLen_list_path, --sample, --out  )", call.=FALSE)
} 

frag.path.list.path <- args[[ "fragmentLen_path" ]]
sample.name <- args[[ "sample" ]]
df <- parse.frag(frag.path.list.path,sample.name)
if( "out" %in% args){
  out.path <- args[["out"]]
  write(frag.len,out.path)}
else{ print(frag.len) }
}

main()