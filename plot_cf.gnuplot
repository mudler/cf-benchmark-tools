set datafile separator ','

set key autotitle columnhead
set ylabel "Time (s)"
set xlabel 'Iteration time (s)'
set title headers

set ytics nomirror format "%.3f"
set xtics nomirror
#set ytics 0.5
#set xtics 1
set xdata time
set timefmt "0%d-%m-%YT%H:%M:%S"

set style line 100 lt 1 lc rgb "grey" lw 0.5
set grid ls 100
set style line 101 lw 2 lt rgb "#7d3ac1"
set style line 102 lw 1 lt rgb "#26dfd0"
set style line 103 lw 2 lt rgb "#f62aa0"
set style line 104 lw 1 lt rgb "#26dfd0"
set style line 105 lw 1 lt rgb "#b8ee30"

set xtics rotate # rotate labels on the x axis
#set key right center # legend placement
set key outside right bottom

set output outputfile
set terminal pngcairo size 1980,1200 enhanced font 'Segoe UI,10'
plot filename using 1:2 with lines ls 101, '' using 1:3 with lines ls 102 , '' using 1:4 with lines axis x1y2 ls 103
