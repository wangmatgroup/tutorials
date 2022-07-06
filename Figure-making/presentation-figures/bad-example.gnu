# example of poor design of plot
set style line 1 lt rgb "green" lw 1
set style line 2 lt rgb "cyan" lw 1

plot 'traj1.dat' u 1 ls 1 w l,\
     'traj2.dat' u 1 ls 2 w l
set xlabel  "num steps" font 'Times-Roman,10'
set ylabel "position"  font 'Times-Roman,10'

