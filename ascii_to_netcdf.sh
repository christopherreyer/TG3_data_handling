#! /bin/bash

#
# to use R a module jneeds to be loaded
#
module load r/3.3.3

#
# execute the R script
#
R CMD BATCH ascii_to_netcdf.r ascii_to_netcdf.r.log

#
# use cdo to set the reference time to 1661
#
cdo --no_history setreftime,1661-01-01,00:00:00 npp_r.nc4 npp_1661.nc4

#
# put the file in the right format and zip it to save space
#
cdo --no_history -f nc4c -z zip_9 copy npp_1661.nc4 npp.nc4

#
# an alternative to cdo are the nco tools
# on DKRZ you need to load the module nco
#
# module load nco/4.6.7-gcc48
#
# for instance, replacing the final cdo command would look like this
#
# ncks -h -O -7 -L 9  npp_1661.nc4 npp.nc4
#
# you can see the file's contents by using
#
# ncview npp.nc4
#
# or
#
# ncdump npp.nc4
