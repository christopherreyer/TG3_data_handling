

# Read netcdf data of model outputs to build txt files

# download files from dkrz server

# libraries to upload
library(ncdf4);library(dplyr); library(tidyr)

# Directory where all files are available -> TO CHANGE
setwd("E:/Profound/UncertaintyAnalysis/OutputData")


#list of all available sites
allfiles=list.files(recursive = TRUE)

# remove LeBray (only needed as long as le_bray naming is not changed to le-bray in database)
is.lebray <- function(x) grepl("bray", x)
allfiles=allfiles[!is.lebray(allfiles)]

# Summary of the models and scenarios available 
sumfiles=do.call(rbind,sapply(1:length(allfiles),function(i) {strsplit(allfiles[i],"\\/|\\_|\\.")}))
sumfiles=sumfiles[,-c(2,3,15,16)]; sumfiles=as.data.frame(sumfiles)
colnames(sumfiles)=c("sim_round","forest_model","gcm","climate_source","CCscenario","management","CO2","variable","site","resolution","start","end")
head(sumfiles)
summary(sumfiles)


# Selection of a specific simulation round, site, and variable
# Here you can add more selection criteria if you want to focus on a specific forest_model or a specific gcm.
myround="FastTrack" #  or "ISIMIP2a" or "ISIMIP2b"
mysite="peitz"
myvariable=c("evap-total")

select=which(sumfiles$sim_round==myround & sumfiles$site==mysite & sumfiles$variable %in% myvariable)

sumselectfiles=sumfiles[select,]
nbsim=length(select)
nbsim

# Resolution of the data
varresolution=unique(sumselectfiles$resolution)


a=0
for (file in allfiles[select])
{
  ncin <- nc_open(file); a=a+1
  
    # Check time -> do it once only
    if (file==allfiles[select][1])
    {
      time<-ncvar_get(ncin,"time")
      tunits<-ncatt_get(ncin,"time",attname="units")
      tustr<-strsplit(tunits$value, " ")
      
      if(tustr[[1]][1]!="years")
      {
        dates<-as.Date(time,origin=unlist(tustr)[3])
        year=as.numeric(format.Date(strptime(dates,"%Y-%m-%d"),"%Y"))
        DOY=as.numeric(format.Date(strptime(dates,"%Y-%m-%d"),"%j"))
      }
      
      if(tustr[[1]][1]=="years")
      {
        # Note: in some netcdf files at annual resolution, the current metadata is wrong [assessed on 09-03-2018]  
        # This will be modified; but in the meantime I use information from the file name, which is correct.
        year=c(as.numeric(as.character(sumselectfiles$start[1])):as.numeric(as.character(sumselectfiles$end[1])))
        DOY=rep(1,length(year))
      }
    outputtable=cbind(year,DOY)
    }
  
    # Variable of interest
    var_array <- ncvar_get(ncin,names(ncin$var))
    
    # Fill with NA values if the simulation end differs
    if (length(var_array)!=nrow(outputtable)){var_array=c(var_array,rep(NA,nrow(outputtable)-length(var_array)))}
    
    # Convert into a better unit
    if (any(myvariable == "evap-total")) {var_array=var_array*3600*24}  # in mm/m2/day 
    
    # merge in output table
    outputtable=cbind(outputtable,var_array)
}

colnames(outputtable)=c("year","DOY",paste0("R",c(1:nbsim)))


# Table with the respective information for each model run
sumselectfiles=cbind(paste0("R",c(1:nbsim)),sumselectfiles); colnames(sumselectfiles)[1]="run"
sumselectfiles


# Calculate cumulative values for daily data
if (varresolution=="daily")
{
  vars_to_process=paste0("R",c(1:nbsim))
  cumsumtable=as.data.frame(outputtable) %>% 
    group_by(year) %>% mutate_at(vars_to_process, funs(cumsum(ifelse(DOY!=1,.,0))))
}

# Generates finaltable, which is our table of interest
  # For daily data, we focus on the values at the end of the year
  if (varresolution=="daily")
    {finaltable=as.data.frame(cumsumtable[c(which(cumsumtable$DOY==1)[-1]-1,nrow(cumsumtable)),])}
  # For annual data, we use the initial data
  if (varresolution=="annual")
    {finaltable=as.data.frame(outputtable)}


# save finaltable
write.csv(finaltable,paste(myround, mysite, myvariable,"finaltable.csv",sep="_"))



# Example of Figure -------------------------------------------------------------------------------------------------

# Plot time-series for each individual run
plot(finaltable[,1],finaltable[,3],pch=16,col=adjustcolor("grey50",0.15),type="l", xlab="years",
     ylab=paste(myvariable),ylim=c(min(finaltable[,c(3:(2+nbsim))],na.rm=TRUE),max(finaltable[,c(3:(2+nbsim))],na.rm=TRUE)))
for (i in 1:(nbsim-1)) {points(finaltable[,1],finaltable[,3+i],col=adjustcolor("grey50",0.15),pch=16,type="l")}

# plot multi-model average
points(finaltable[,1],rowMeans(finaltable[,3:nbsim],na.rm=TRUE),col="grey50",type="l",lwd=3)



