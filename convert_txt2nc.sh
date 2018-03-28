#!/bin/bash

# at DKRZ: make CDO tool available
module purge
module load cdo/1.8.2-gcc48

# define variable and global properties
LAT="52.5";LON="13.2"
FILE_IN="npp.txt"
VAR="npp"
STD_NAME="npp"
LONG_NAME="Net Primary Production"
UNIT="kg m-2 s-1"
STARTYEAR="1990" # first year of data time series
TIME_RES="years" # days, months, years
CALENDAR="standard" # standard (gregorian), proleptic_gregorian, noleap, 365_day or 360_day
INSTITUTION="Potsdam-Institute for Climate Impact Research (PIK)"
CONTACT="ISIMIP Team <info@isimip.org>" # include Author Name and <email>, add more contacts comma separated

export CDO_VERSION_INFO=0

# get input file extension
FILE_EXT="${FILE_IN##*.}"

# prepare gridfile
GRIDFILE=gridfile.run
sed -e s/_LON_/$LON/ -e s/_LAT_/$LAT/ < gridfile.template > $GRIDFILE # replace place holders im template file with actual values

# write FILE_IN to NetCDF
cdo -s -f nc4c --no_history \
    -setreftime,1661-01-01,00:00:00,1$TIME_RES \
    -settaxis,$STARTYEAR-01-01,00:00:00,1$TIME_RES \
    -setattribute,institution="$INSTITUTION",contact="$CONTACT" \
    -setattribute,$VAR@standard_name="$STD_NAME",$VAR@long_name="$LONG_NAME" \
    -setname,$VAR -setunit,"$UNIT" -setcalendar,$CALENDAR \
    -setmissval,1e+20 -setgrid,$GRIDFILE -input,r1x1 \
    $(basename $FILE_IN $FILE_EXT)nc4 < $FILE_IN  # expect data in the first column and replace file extension (basename)

# clean up
rm $GRIDFILE
