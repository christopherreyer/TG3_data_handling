# TG3_data_handling
collection of scripts to handle ISIMIP/PROFOUND simulation data:

convert_txt2nc.sh = bash script to convert ascii files into netcdf-flies according to ISIMIP standards, requires the file gridfile.template and npp.txt; by Matthias Büchner

ascii_to_netcdf.r = R-script to convert ascii files into netcdf-flies according to ISIMIP standards, requires the file npp.txt and needs to be run through the file ascii_to_netcdf.sh; by Jan Volkholz

PROFOUND-read-modelsoutputs.R = R-script to load netcdf files into R and do some first analyses; by Maxime Cailleret


