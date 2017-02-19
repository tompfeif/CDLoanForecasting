#CD and Loan Forecasting
#--------- INSTALL & LOAD PACKAGES ------------
library(ggplot2)
library(scales) #scale plots
library(gridExtra) # Multiple ggplot graphs on one plot with grid.arrange()
library(forecast) # Create forecasts
library(tseries) # Time series analysis and Dickey-Fuller test
library(corrplot) # Correlation matrix
library(tidyr) # make "wide" data "long" with gather() function
#------------ IMPORT DATA & FORMAT --------------
allData <- read.csv("/Users/ThomasPfeiffer/Documents/R Programming/Cobelen/InformeFinanciero_Cobelen.csv", 
                    stringsAsFactors=FALSE, header=TRUE)
mydata <- allData[, c("Agencia", "Fecha", "SaldoCartera", "SaldoCDAT")]
mydata[,-1:-2] <- sapply(mydata[,-1:-2], function(x)as.numeric(gsub(",","", x)))
mydata$Agencia <- as.factor(mydata$Agencia)
mydata$Fecha <- as.Date(mydata$Fecha, format = "%m/%d/%y")
# ----- Create TS for 12 Branches and Total -----
zdata <- setNames(gather(mydata, "cdOrLoan", "values", 3:4), c('branch','date','cdOrLoan','values'))
ztsdata <- spread(zdata, branch, values)
zloan <- setNames(ztsdata[cdata$cdOrLoan == "SaldoCartera",-2], c('date','oneL','twoL','threeL','fourL','fiveL','sixL','sevenL','eightL','nineL','tenL','elevenL','twelveL'))
zcd <- setNames(ztsdata[cdata$cdOrLoan == "SaldoCDAT",-2], c('date','oneCd','twoCd','threeCd','fourCd','fiveCd','sixCd','sevenCd','eightCd','nineCd','tenCd','elevenCd','twelveCd'))
tsdata <- cbind(zloan, zcd[,-1])
tsdata$lTotal <- apply(zloan[,-1], MARGIN = 1, sum) #create loan and cd totals
tsdata$cdTotal <- apply(zcd[,-1], MARGIN = 1, sum)
#--------- PLOT THE DATA -----------
#Rearrange data for easier plotting
zpdata <- setNames(data.frame(rep("T",45),tsdata$date, tsdata$lTotal, tsdata$cdTotal), c('branch','date', 'SaldoCartera', 'SaldoCDAT'))
zpdata <- gather(zpdata, "cdOrLoan","values",3:4)
pdata <- rbind(zdata,zpdata)
#plot
options(scipen=5) #avoid scientific notation in plot
ggplot(pdata[pdata$branch=="T",], aes(date, values, col=reorder(factor(cdOrLoan, labels = c("Loans", "CD")), -values))) + geom_line() +
        labs(title ="Total Balances", x = "Date", y = "Balance (millions)", color = "") +
        theme( plot.title = element_text( size = rel( 2 ), hjust = 0.5 ), legend.key = element_rect( color = "black" ) ) +
        scale_y_continuous(labels = function(x)x/1000000)
ggplot(mydata, aes(Fecha, SaldoCDAT, color = reorder(Agencia, -SaldoCDAT))) + geom_line() + 
        labs(title = "CD Balances by Branch", x = "Date", y = "CD Balance (millions)", color = "Branch") +
        theme( plot.title = element_text( size = rel( 2 ), hjust = 0.5 ), legend.key = element_rect( color = "black" ) ) +
        scale_y_continuous(labels = function(x)x/1000000)
ggplot(mydata, aes(Fecha, SaldoCartera, color = reorder(Agencia, -SaldoCartera))) + geom_line() + 
        labs(title = "Loan Balances by Branch", x = "Date", y = "Loan Balance (millions)", color = "Branch") +
        theme( plot.title = element_text( size = rel( 2 ), hjust = 0.5 ), legend.key = element_rect( color = "black" ) ) +
        scale_y_continuous(labels = function(x)x/1000000)
#all branches
for(i in 1:12){
        g <- ggplot(pdata[pdata$branch==i,], aes(date, values, color=factor(cdOrLoan,labels=c("Loans", "CD"))))+
                geom_line() + 
                labs(title= paste("Branch ", i, sep=""), x="Date", y="Balance (millions)", color="CD or Loan") + 
                theme(plot.title=element_text(size=rel(2), hjust=0.5), legend.key=element_rect(color="black")) + 
                scale_y_continuous(labels=function(x)x/1000000)
        assign(paste("b", i, "_graph", sep = ""), g)
}
grid.arrange(b1_graph, b2_graph, b3_graph, b4_graph, b5_graph, b6_graph, ncol = 2)
grid.arrange(b7_graph, b8_graph, b9_graph, b10_graph, b11_graph, b12_graph, ncol = 2)
#-------------- TIME SERIES FORECASTING -------------------
tsdata$nineL[1:7] <- tsdata$nineL[8]#Branch 9 loan data correction for serious mean shift from periods 7:8
#create dataframes to hold forecasts and models
dates <- seq(as.Date("2016-08-01"), length=18, by="1 month") -1
forecasts <- data.frame(dates, matrix(0, nrow = 18, ncol = 26))
colnames(forecasts) <- colnames(tsdata)
models[,1] <- c("arima","ets")
armodels <- sapply(colnames(tsdata),function(x) NULL)
etsmodels <- sapply(colnames(tsdata),function(x) NULL)
for(i in 2:27){
        armodel <- auto.arima(tsdata[,i])
        etsmodel <- ets(tsdata[,i])
        arfcast <- forecast(armodel, h=18)
        etsfcast <- forecast(etsmodel, h=18)
        forecasts[,i] <- (arfcast$mean + etsfcast$mean) / 2
        armodels[[i]] <- as.character(forecast(armodel)$method)
        etsmodels[[i]] <- as.character(etsmodel$method)
}
models <- data.frame("Branch"=colnames(tsdata[-1]),"arima models"=matrix(unlist(armodels), nrow=26, byrow=T),
                     "ets models"=matrix(unlist(etsmodels), nrow=26, byrow=T),stringsAsFactors=FALSE)
#plot forecasts
finaldata <- rbind(tsdata, forecasts) #all point forecasts
gtl <- ggplot(finaldata, aes(date, finaldata$lTotal)) + geom_line() + geom_line(data=forecasts, aes(date, forecasts$lTotal), color="red") +                labs(title=paste("Branch ",(i-1),x," Forecast"), x = "Date", y = "Balance (millions)") +
        theme(plot.title = element_text(size=rel(1.1), hjust=0.5), plot.subtitle= element_text(size=rel(.6), hjust=0.5)) +
        labs(subtitle=paste(models[25,2], " & ", models[25,3])) +
        scale_y_continuous(labels = function(x)x/1000000)
gtcd <- ggplot(finaldata, aes(date, finaldata$cdTotal)) + geom_line() + geom_line(data=forecasts, aes(date, forecasts$cdTotal), color="red") +                labs(title=paste("Branch ",(i-1),x," Forecast"), x = "Date", y = "Balance (millions)") +
        theme(plot.title = element_text(size=rel(1.1), hjust=0.5), plot.subtitle= element_text(size=rel(.6), hjust=0.5)) +
        labs(subtitle=paste(models[26,2], " & ", models[26,3])) +
        scale_y_continuous(labels = function(x)x/1000000)
grid.arrange(gtl,gtcd, ncol = 2)

