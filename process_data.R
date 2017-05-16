process_data<-function(infile)
{  
raw_data<-read.csv(file=infile, as.is=TRUE,sep = ",",header=TRUE)

#remove crap at the end
raw_data <- raw_data[raw_data$Sample.Name != "",]



raw_data$sample_lot<-paste0(unlist(lapply(raw_data$Sample.Name, function(x) strsplit(x,"_")[[1]][1])))


t<-unlist(lapply(raw_data$Sample.Name, function(x) strsplit(x,"#")[[1]][2]))

raw_data$t[!is.na(t)] <- substr(t[!is.na(t)],1,1)

clean_data <- raw_data[!is.na(raw_data$t),]

clean_data<- clean_data[,c("Calc.Conc.","t","sample_lot")]

clean_data$Calc.Conc. <- as.numeric(clean_data$Calc.Conc.)

clean_data$Calc.Conc.<- round(clean_data$Calc.Conc.,digits = 2)

clean_data

#saveRDS(clean_data,file=outfile)
}
#process_data("AbbvieUseCase2CInstrumentData.csv")
