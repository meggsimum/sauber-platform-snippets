#!/usr/bin/env bash

# usage: import_data.sh PACKAGE_FOLDER
# This is a helper script to import new data into a running container.
# The first shot is very simple and just copies files into GEOSERVER_DATA_DIR. 

set -e

# Sanity checks
if [ $# -ne 1 ]
  then
    echo "error: No module data location specified as command line argument"
    exit 1
fi

if [ ! -d $1 ]; then
    echo "error: Source directory $1 does not exist"
    exit 1
fi

# Copy the data.
# Exit with an error, if a target file would be overwritten.
echo
        echo "processing $1"
echo

if [ -n "$(false | cp -ir "$1"/* "${GEOSERVER_DATA_DIR}" 2>&1)" ] 
then 
    echo "error: File collision detected, aborting import"
    exit 1
fi

echo
		echo "Geoserver update process for $1 complete."
echo
