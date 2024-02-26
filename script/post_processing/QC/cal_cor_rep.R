#!/usr/bin/env	Rscript
library(tidyverse)
library(rtracklayer)

get_peak_file <- function(peak_files){
  peak_name <- peak_files %>% basename %>% str_remove("_CPM.bw")
  CR_gr <- lapply(peak_files, function(x){
    gr <- import(x) %>% keepStandardChromosomes(pruning.mode="coarse")
    gr <- gr[score(gr)>1]
  })  
}

get_union_mtx <- function(peak_list){
  peak_union <- do.call(c, peak_list) %>% GenomicRanges::disjoin()
}

get_peak_count_mtx <- function(peak_list,peak_union){
  peak_count_mtx <- lapply(peak_list, function(x){ o <- rep(0,peak_union %>% length) 
  idx<-findOverlaps(peak_union,x)
  o[idx@from]<- x$score[idx@to] 
  o}) %>% bind_cols()
}

plot_cor <- function(peak_count_mtx){
    cor(peak_count_mtx)  %>%
    as_tibble() %>% 
    rownames_to_column() %>%  
    gather(key = "att", value ="cor" ,-rowname) %>%
    ggplot(data = . , aes(x = att , y = rowname , fill = cor)) +
    geom_tile() +
    scale_fill_gradient2(midpoint = 0.5, 
                         limits = c(-1, +1)) +
    labs(title = "Correlation Matrix", 
         x = "", y = "", fill = "Correlation \n Measure") +
    geom_text(aes(x = att, y = rowname, label = round(cor, 2)), color = "black", 
              fontface = "bold", size = 5)
  
}
main	<-	function(){
  args	<-	commandArgs(asValues=TRUE)

  if	(length(args)	<	3	)	{
    stop("four	arguments	must	be	supplied	(--bigwig_path,--out_path)",	call.=FALSE)
  }	
  
  bigwig_path	<-	args[["bigwig_path"]]
  out_path <- args[["out_path"]]
  peak_file_ext <- "cpm/.+bw$"
  peak_file_regex <- ".*"
  
  peak_files<- list.files(bigwig_path,recursive=T, full.names = TRUE) %>% str_subset(peak_file_ext) %>% str_subset(peak_file_regex) %>% unlist
  peak_name <- peak_files %>% basename 
  gr <- get_peak_file(peak_files)
  gr_union <- get_union_mtx(gr)
  gr %>% setNames(peak_name)
  gr_mtx <- get_peak_count_mtx(gr,gr_union)
  (
    plot_cor(gr_mtx) 
    ) %>% 
    ggsave(out_path)

}

main()