

plot_data<-function(data,outfile)

{
library(ggplot2)

p<-ggplot(data,aes(y=Calc.Conc.,x=t))
p<-p+geom_point()
p<-p+ labs(x="days")
p<- p +facet_wrap(~sample_lot,scales = "free",ncol = 6)


pdf(outfile,width = 8,height = 10)
plot(p)
dev.off()
}
#plot_data(clean_data,"plot.pdf")
