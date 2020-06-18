#!/bin/bash
# usage: create_graphs <dir>

ROOT_DIR="${1:-$PWD}"

for i in `ls ${ROOT_DIR%/}/*.csv | sort -V`; do
    FILE="$i";
    OUTPUT="$ROOT_DIR/$(basename $i .csv).png";
    echo "Generating chart $OUTPUT from $FILE"
    PLOTTITLE=$(grep -i -e header -e footer $(echo $FILE) | sed s/\"\//g | sed s/\#//g);
    gnuplot -e "headers='${PLOTTITLE}'; filename='${FILE}'; outputfile='${OUTPUT}';" plot.gnuplot
done;
