#!/usr/bin/perl -w

use strict;
use FindBin;

my $home = "$FindBin::Bin";

if ($#ARGV != 2 and $#ARGV != 3) {
  print "plotHistograms.pl <number_of_states> <number_of_solutions> <hist_interval> <generate_models>\n";
  exit;
}

my $N = $ARGV[0];
my $n = $ARGV[1];
my $interval = $ARGV[2];
my $generate_models = 0;
if($#ARGV == 3) { $generate_models = 1; }

`rm -f chis`;
my $input_chi = `grep Chi input_iq.dat | cut -d ' ' -f11`;
chomp $input_chi;
#`echo 0 $input_chi 0 > chis`;
for(my $i = 1; $i <= $N; $i++) {
  my $ensemble_file = "ensembles_size_" . $i . ".txt";
  if(-e $ensemble_file) {
    my $last_file_name = "e" . $i . "/e" . $n . "_0.pdb";
    my $rg_out_file = "rg" . $i;
    if((not -e $last_file_name) and $generate_models == 1) {
      #print "$home/getModels.pl $ensemble_file 1 $n\n";
      `$home/getModels.pl $ensemble_file 1 $n > $rg_out_file`;

      my $dirname = "e" . $i;
      `rm -f e???_[0-5].pdb`;
      `mkdir $dirname; mv e*_*.pdb $dirname`;

    }
    my $num = $n*$i;
    `head -$num $rg_out_file > rg_tmp.out`;
    my $hist_file = "hist" . $i;
    `$home/histogram.pl $interval < rg_tmp.out > $hist_file`;
    `$home/getMinMaxScore.pl $ensemble_file $n >> chis`;
  }
}


`$home/histogram.pl $interval < rg > hist`;

# prepare chi-size plot
my $first_line = `head -n1 chis`;
my @tmp = split(' ', $first_line);
my $yrange = $tmp[1] + $tmp[2] + 0.5;
if($tmp[2] > $tmp[1]) { $yrange = $tmp[1]*2; }
my $x = `sed 's/YRANGE/$yrange/g' $home/plotbar.plt > plotbar.plt`;
`$home/gnuplot-4.6.0/src/gnuplot plotbar.plt`;

# hist plot
$first_line = `head -n1 hist`;
@tmp = split(' ', $first_line);
my $xrange1 = $tmp[2] - $interval -2;
my $xrange2 = $tmp[5] + $interval +2;
$x = `sed 's/XRANGE1/$xrange1/g' $home/gnuplot.txt | sed 's/XRANGE2/$xrange2/g' > gnuplot.txt`;
`$home/gnuplot-4.6.0/src/gnuplot gnuplot.txt`;

# jsmol canvas
my @colors = ( "\#1a9850", #green                                                                                               
               "\#e26261", # red                                                                                                
               "\#3288bd", #blue                                                                                                
               "\#00FFFF",
               "\#A6CEE3");


my $profile_file_name = "iq.dat";
open JSOUT, ">canvas_ensemble.plt";
print JSOUT "set terminal canvas solid butt size 300,250 fsize 10 lw 1.5 fontscale 1 name \"jsoutput_3\" jsdir \".\"\n";
print JSOUT "set output 'jsoutput.3.js'; set multiplot; set origin 0,0;set size 1,0.3; set tmargin 0;set xlabel 'q';set ylabel ' ' offset 1;set format y '';set xtics nomirror;set ytics nomirror;unset key;set border 3; set style line 11 lc rgb '#808080' lt 1;set border 3 back ls 11;f(x)=1\n";
my $residuals_string = "plot f(x) lc rgb '#333333'" ;
my $plots_string = "plot '" . $profile_file_name . "' u 1:2 lc rgb '#333333' pt 6 ps 0.8";

for(my $state_number = 1; $state_number <= $N; $state_number++) {
  my $out_file = "multi_state_model_".$state_number."_1_1.dat";
  $residuals_string .= ", '" . $out_file . "' u 1:(\$2/\$3) w lines lw 2.5 lc rgb '" . $colors[$state_number-1] . "'";
  $plots_string .= ", '" . $out_file . "' u 1:3 w lines lw 2.5 lc rgb '" . $colors[$state_number-1] . "'";
}
print JSOUT "$residuals_string\n";
print JSOUT "set origin 0,0.3;set size 1,0.69; set bmargin 0;set xlabel ''; set format x ''; set ylabel 'intensity (log-scale)' offset 1; set log y\n";
print JSOUT "$plots_string\n";
print JSOUT "unset multiplot\n";
close JSOUT;

`$home/gnuplot-4.6.0/src/gnuplot canvas_ensemble.plt`;

open JSOUT1, ">input.plt";
print JSOUT1 "set terminal canvas solid butt size 300,250 fsize 10 lw 1.5 fontscale 1 name \"jsoutput_1\" jsdir \".\"\n";
print JSOUT1 "set output 'jsoutput.1.js'; set multiplot; set origin 0,0;set size 1,0.3; set tmargin 0;set xlabel 'q';set ylabel ' ' offset 1;set format y '';set xtics nomirror;set ytics nomirror;unset key;set border 3; set style line 11 lc rgb '#808080' lt 1;set border 3 back ls 11;f(x)=1\n";
$residuals_string = "plot f(x) lc rgb '#333333'" ;
$plots_string = "plot '" . $profile_file_name . "' u 1:2 lc rgb '#333333' pt 6 ps 0.8";
my $out_file = "input_iq.dat";
$residuals_string .= ", '" . $out_file . "' u 1:(\$2/\$3) w lines lw 2.5 lc rgb '" . $colors[0] . "'";
$plots_string .= ", '" . $out_file . "' u 1:3 w lines lw 2.5 lc rgb '" . $colors[0] . "'";
print JSOUT1 "$residuals_string\n";
print JSOUT1 "set origin 0,0.3;set size 1,0.69; set bmargin 0;set xlabel ''; set format x ''; set ylabel 'intensity (log-scale)' offset 1; set log y\n";
print JSOUT1 "$plots_string\n";
print JSOUT1 "unset multiplot\n";
close JSOUT1;

`$home/gnuplot-4.6.0/src/gnuplot input.plt`;
