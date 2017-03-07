#set terminal postscript eps size 3.0,2.1 color enhanced solid linewidth 2.5 font 'Helvetica,18';
set terminal png enhanced font '/netapp/sali/dina/MultiFoXSServer/gnuplot-4.6.0/Vera.ttf, 10' size 290,240
set output "chis.png"
set style line 11 lc rgb '#808080' lt 1; set border 3 back ls 11;set xtics nomirror;set ytics nomirror

set style line 1 lc rgb 'gray30' lt 1 lw 1
set style line 2 lc rgb 'gray40' lt 1 lw 1
#set style fill solid 1.0 border rgb 'grey30'
set style fill solid 1.0 border rgb '#596E98'
bs = 0.2

set yrange [0:YRANGE];set ylabel 'x' offset 1;
set xrange [0.5:5.5]; set xlabel '# of states'
set xtics 1
plot 'chis' u 1:2:3 notitle w yerrorb ls 1, '' u 1:2:(bs) notitle w boxes ls 2
reset
