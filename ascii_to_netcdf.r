#
# load the ncdf4 package
#
# documentation: https://cran.r-project.org/web/packages/ncdf4/ncdf4.pdf
#
library("ncdf4")

#
# set some variables
#
lon <- 12.3
lat <- -43.9
start.year <- 2023
missing.value <- 1e20

#
# read in data, it is stored in a data frame
#
npp.data.frame <- read.table("npp.txt")

#
# get data out of the data frame into a regular vector
#
n.values <- dim(npp.data.frame)[1]
npp.data <- npp.data.frame[1:n.values,1]

#
# create dimensions for NetCDf file
#
# we set the attribute "standard_name" later
#
dim.lon <- ncdim_def(name = "lon", longname="longitude", units = "degrees_east", vals = lon)
dim.lat <- ncdim_def(name = "lat", longname="latitude",  units = "degrees_north", vals = lat)

#
# calendar can be either "standard" (== "gregorian"), "noleap" (== "365_day")
# or "360_day"
#
dim.time <- ncdim_def("time", units=paste("days since ", start.year,"-01-01 00:00:00", sep=""), vals = c(0:(n.values-1)), calendar="gregorian")

#
# now add the variable to the file
#
nc.var <- ncvar_def(name = "npp", longname= "Net Primary Production", units = "kg m-2 s-1", dim = list(dim.lon,dim.lat,dim.time), missval = missing.value)

#
# create NetCDF file
#
nc.file <- nc_create("npp_r.nc4", list(nc.var))

#
# set global attributes
# add similar lines for the other required global attributes
#
ncatt_put(nc.file, 0, attname = "institution", attval = "some institute", prec="text")

#
# put the data into the file
#
ncvar_put(nc.file, nc.var, npp.data)

#
# add variable attributes still missing
#
ncatt_put(nc.file, "npp", attname = "standard_name", attval = "npp", prec="text")
ncatt_put(nc.file, "npp", attname = "missing_value", attval = missing.value, prec="float")

#
# we're done, finish the file creation
#
nc_close(nc.file)
