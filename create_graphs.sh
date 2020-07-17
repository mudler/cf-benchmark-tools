#!/bin/bash
# usage: create_graphs <dir>

if ! [ -x "$(command -v gnuplog)" ]; then 
    echo "Gnuplot not installed, exiting"
    exit 0
fi

ROOT_DIR="${1:-$PWD}"
PLOT="${PLOT:-plot.gnuplot}"
for i in `ls ${ROOT_DIR%/}/*.csv | sort -V`; do
    FILE="$i";
    OUTPUT="$ROOT_DIR/$(basename $i .csv).png";
    echo "Generating chart $OUTPUT from $FILE"
    PLOTTITLE=$(grep -i -e header -e footer $(echo $FILE) | sed s/\"\//g | sed s/\#//g);
    gnuplot -e "headers='${PLOTTITLE}'; filename='${FILE}'; outputfile='${OUTPUT}';" $PLOT
done;
