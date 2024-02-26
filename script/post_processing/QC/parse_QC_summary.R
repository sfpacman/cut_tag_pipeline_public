#!/usr/bin/env	Rscript
library(R.utils, warn.conflicts	=	FALSE)
library(dplyr)
parse.bam.qc	<-	function(path,	Sample)	{
	alignRes	<-	read.table(path,	header	=	FALSE,	fill	=	TRUE)
	alignRate	<-	substr(alignRes$V1[6],	1,	nchar(as.character(alignRes$V1[6]))-1)
	alignResult	 <-	data.frame(Sample	=	Sample,	
	'Sequencing_Depth'	=	alignRes$V1[1]	%>%	as.character	%>%	as.numeric,	
	'Mapped_Frag_Num_hg38_bowtie'	=	alignRes$V1[4]	%>%	as.character	%>%	as.numeric	+	alignRes$V1[5]	%>%	as.character	%>%	as.numeric,	
	'Alignment_Rate_hg38_bowtie'	=	alignRate	%>%	as.numeric)
	return(alignResult)
}

parse.bam.spikein.qc	<-	function(path,	Sample)	{
	spikeRes	<-	read.table(path,	header	=	FALSE,	fill	=	TRUE)
	alignRate	<-	substr(spikeRes$V1[6],	1,	nchar(as.character(spikeRes$V1[6]))-1)
	spikeAlign	<-	data.frame(Sample	=	Sample,	
	'Sequencing_Depth'	<-	spikeRes$V1[1]	%>%	as.character	%>%	as.numeric,	
	'Mapped_Frag_Num_spikeIn'	=	spikeRes$V1[4]	%>%	as.character	%>%	as.numeric	+	spikeRes$V1[5]	%>%	as.character	%>%	as.numeric,	
	'Alignment_Rate_spikeIn'	=	alignRate	%>%	as.numeric)
	return(spikeAlign)
}

parse.picard	<-function(path,Sample)	{
	dupRes	<-	read.table(path,header	=	TRUE,	fill	=	TRUE)	
	dupResult	<-	data.frame(Sample	=	Sample,	
	'Mapped_Frag_Num_hg38_picard'	=	dupRes$READ_PAIRS_EXAMINED[1]	%>%	as.character	%>%	as.numeric,	
	'Duplication_Rate'	=	dupRes$PERCENT_DUPLICATION[1]	%>%	as.character	%>%	as.numeric	*	100,	
	'Estimated_Library_Size'	=	dupRes$ESTIMATED_LIBRARY_SIZE[1]	%>%	as.character	%>%	as.numeric)	%>%	mutate(Unique_Frag_Num	=	Mapped_Frag_Num_hg38_picard	*	(1-Duplication_Rate/100))
	return(dupResult)
	}

parse.frag	<-	function(path,Sample){
	fragLen	<-	read.table(path,	header	=	FALSE)	%>%	mutate('frag_Len'	=	as.numeric(V1),	'frag_Count'	=	as.numeric(V2),	'Weight'	=	as.numeric(V2)/sum(as.numeric(V2)),	Sample	=	Sample)	
	return(fragLen)
	}

get.frag.stat	<-	function(frag.df){
	frag.stat.df	<-	frag.df	%>%	filter(	frag_Count	==	median(frag_Count)	)	%>%	select(Sample,frag_Len) %>% group_by(Sample) %>% summarize('frag_Len_Mean' = 
    mean(frag_Len, na.rm=TRUE))
  return(as.data.frame(frag.stat.df))
}
infer.spikein.scale.factor	<-	function(path,Sample,c=10000){
	spikein.infer	<-	read.table(path,header=FALSE)	%>%	mutate('Alignment_Rate_spikeIn_infer' =	as.numeric(V1)/10000	-	1, 'Sample' = Sample) %>% rename('Scale_Factor' = V1)
	return(spikein.infer)
}
parse.frip <- function(path, Sample){
	frip <- read.table(path, header = FALSE) %>% mutate('FRiP' = as.numeric(V1), 'Sample' = Sample) %>% select('FRiP', 'Sample')
	return(frip)
}

main	<-	function(){

#args0	<-	R.utils::commandArgs()
args	<-	commandArgs(asValues=TRUE)
#stopifnot(all.equal(args,	args0,	check.attributes=FALSE))

if	(length(args)	<	5	)	{
	stop("four	arguments	must	be	supplied	(--fragmentLen_list_path,--picard_log_path,--bowtie2_log_path	,--bowtie2_spikein_log_path,--sample,	--output_file, --frip_path	)",	call.=FALSE)
}	
#Assigning	path
bowtie2.log.path	<-	args[["bowtie2_log_path"]]
bowtie2.spikein.log.path	<-	args[["bowtie2_spikein_log_path"]]
picard.log.path	<-	args[["picard_log_path"]]
frag.path.list.path	<-	args[[	"fragmentLen_list_path"	]]
infer.spikein.scale.factor	<-	args[[	"scale_factor"]]
sample.name	<-	args[[	"sample"	]]
out.path	<-	args[["output_file"]]
frip.path <- args[["frip_path"]]
#add frip score

#parsing	and	merge	DataFrame
align.result.df	<-	parse.bam.qc(bowtie2.log.path,sample.name)
#align.result.spikein.df	<-	parse.bam.spikein.qc(bowtie2.spikein.log.path,sample.name)
dup.result.df	<-	parse.picard(picard.log.path,sample.name)
frag.len.df	<-	parse.frag(	frag.path.list.path,sample.name)
frag.len.stat.df	<-	get.frag.stat(frag.len.df)
print(frag.len.stat.df)
infer.spikein.df	<-	infer.spikein.scale.factor(	infer.spikein.scale.factor,sample.name)
frip.df <- parse.frip(frip.path, sample.name)
#qc.df.list	<-	list(align.result.df,align.result.spikein.df,dup.result.df,frag.len.stat.df)
qc.df.list	<-	list(align.result.df,dup.result.df,infer.spikein.df, frip.df)

final.df	<-	Reduce(function(x, y)	merge(x,	y, by="Sample"),	qc.df.list	)
write.csv(final.df,out.path,	row.names=FALSE)

}

main()