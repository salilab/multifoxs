#!/usr/bin/perl -w

use strict;
use File::Copy;
use CGI qw/:standard/;
use FindBin;
my $home = "$FindBin::Bin";
require "$home/UTIL.pm";

if ($#ARGV != 0) {
  print "showResultsMultiFoXS.pl <directory>\n";
  exit;
}

my $runs="/modbase4/home/multifoxs/service/completed/";
my $dirname = $ARGV[0];
my $profileFileName = "iq.dat";

my $profileFile = $profileFileName;
$profileFile = UTIL::trimExtension($profileFileName);

my $results_dir = $runs.$dirname;

chdir $results_dir or die "Couldn't change to directory $results_dir\n";

my @colors = ( "\#1a9850", #green
               "\#e26261", # red
               "\#3288bd", #blue
               "\#00FFFF",
               "\#A6CEE3");

my @colors2 = ( "[x1a9850]", #green
               "[xe26261]", # red
               "[x3288bd]", #blue
               "[x00FFFF]",
               "[xA6CEE3]");

my $maxStateNumber = 4;
#plotHistogram($maxStateNumber, 10);

# prepare gnuplot canvas plot for profiles
open JSOUT, ">canvas_ensemble.plt";
print JSOUT "set terminal canvas solid butt size 300,250 fsize 10 lw 1.5 fontscale 1 name \"jsoutput_3\" jsdir \".\"\n";
print JSOUT "set output 'jsoutput.3.js'; set multiplot; set origin 0,0;set size 1,0.3; set tmargin 0;set xlabel 'q';set ylabel ' ' offset 1;set format y '';set xtics nomirror;set ytics nomirror;unset key;set border 3; set style line 11 lc rgb '#808080' lt 1;set border 3 back ls 11;f(x)=1\n";
my $residuals_string = "plot f(x) lc rgb '#333333'" ;
my $plots_string = "plot '" . $profileFileName . "' u 1:2 lc rgb '#333333' pt 6 ps 0.8";
my $gnuplot_string = "<script> gnuplot.show_plot(\"jsoutput_3_plot_2\"); </script>";
for(my $stateNumber = 1; $stateNumber <= $maxStateNumber; $stateNumber++) {
  my $out_file = "multi_state_model_".$stateNumber."_1_1.dat";
  $residuals_string .= ", '" . $out_file . "' u 1:(\$2/\$3) w lines lw 2.5 lc rgb '" . $colors[$stateNumber-1] . "'";
  $plots_string .= ", '" . $out_file . "' u 1:3 w lines lw 2.5 lc rgb '" . $colors[$stateNumber-1] . "'";
  my $plotnum = $stateNumber+1;
  if($stateNumber != 2 && $stateNumber != 1) {
    $gnuplot_string .= "<script> gnuplot.hide_plot(\"jsoutput_3_plot_$plotnum\"); </script>";
  }
}
print JSOUT "$residuals_string\n";
print JSOUT "set origin 0,0.3;set size 1,0.69; set bmargin 0;set xlabel ''; set format x ''; set ylabel 'intensity (log-scale)' offset 1; set log y\n";
print JSOUT "$plots_string\n";
print JSOUT "unset multiplot\n";
close JSOUT;
`/modbase5/home/foxs/www/foxs/gnuplot-4.6.0/src/gnuplot canvas_ensemble.plt`;

print "<p><table align=center>";
print "<tr><th>MultiFoXS Results </th></tr><tr>";

print "<table align = center><tr><td align=center><div  id=\"wrapper2\"><img src=\"chis.png\" height=250 width=300></div></td>\n";

UTIL::printCanvas();

print "<script src=\"/foxs/runs/$dirname/jsoutput.3.js\"></script>\n";
print "<td><div  id=\"wrapper2\">
<canvas id=\"jsoutput_3\" height=250 width=300 tabindex=\"0\" oncontextmenu=\"return false;\">
<div class='box'><h2>Your browser does not support the HTML 5 canvas element</h2></div>
</canvas>
 <div id=\"buttonWrapper\">
  <input type=\"button\" id=\"minus\"   onclick=\"gnuplot.unzoom();\">
            </div></div>
<script>
  if (window.attachEvent) {window.attachEvent('onload', jsoutput_3);}
else if (window.addEventListener) {window.addEventListener('load', jsoutput_3, false);}
else {document.addEventListener('load', jsoutput_3, false);}
</script>
</td>\n";

print $gnuplot_string;

print "</tr></table></tr>\n";

print "<script type=\"text/javascript\" src=\"/foxs/jsmol2/js/JSmoljQuery.js\"></script>\n";
print "<script type=\"text/javascript\" src=\"/foxs/jsmol2/js/JSmoljQueryExt.js\"></script>\n";
print "<script type=\"text/javascript\" src=\"/foxs/jsmol2/js/JSmolCore.js\"></script>\n";
print "<script type=\"text/javascript\" src=\"/foxs/jsmol2/js/JSmolApplet.js\"></script>\n";
print "<script type=\"text/javascript\" src=\"/foxs/jsmol2/js/JSmolApi.js\"></script>\n";
print "<script type=\"text/javascript\" src=\"/foxs/jsmol2/js/j2sjmol.js\"></script>\n";
print "<script type=\"text/javascript\" src=\"/foxs/jsmol2/js/JSmol.js\"></script>\n";


print "<script type=\"text/javascript\">\n";
print "var myInfo1 = {\n";
print "        height: '98%',\n";
print "        width: '98%',\n";
print "        jarFile: \"JmolApplet.jar\",\n";
print "        jarPath: \"/foxs/jsmol2/../\",\n";
print "        j2sPath: \"/foxs/jsmol2/j2s/\",\n";
print "        use: 'HTML5',\n";
print "        console: \"myJmol1_infodiv\",\n";
print "        debug: false\n";
print "};\n";
print "</script>";

if(-e "ensembles_size_2.txt") {
  printMultiStateModel("ensembles_size_2.txt", 2, 1, $colors2[1]);
}

if(-e "ensembles_size_3.txt") {
  printMultiStateModel("ensembles_size_3.txt", 3, 1, $colors2[2]);
}

if(-e "ensembles_size_4.txt") {
  printMultiStateModel("ensembles_size_4.txt", 4, 1, $colors2[3]);
}


print "</table></body>";

UTIL::printFooter();

sub printMultiStateModel {
    my ($dirname, $res_file_name, $state_number, $model_number, $color) = @_;

    open(DATA, $res_file_name);
    while(<DATA>) {
        chomp;
        if(index($_, " x1 ") != -1) {
            my @tmp=split('\|',$_);
            if($#tmp>0 and $tmp[0] =~/\d/) {
                my $curr_model_number = int $tmp[0];
                if($curr_model_number == $model_number) {
                    my $score = $tmp[1];
                    my @c1c2 = split('\(', $tmp[2]);
                    my @tmpp = split(',', $c1c2[1]);
                    my $c1 = $tmpp[0];
                    @c1c2 = split('\)', $tmpp[1]);
                    my $c2 = $c1c2[0];
                    my $plotnum = $state_number+1;
                    print "<tr><th> <b> Best scoring $state_number-state model &chi; = $score  c<sub>1</sub> = $c1  c<sub>2</sub> = $c2\n";
          # print checkbox                                                                                                                                                                                         
                    print "<input type=checkbox id='chbx$plotnum' onchange='func$plotnum()'";
                    if($state_number == 2) { print " checked"; }
                    print ">\n";
                    print "<script type=\"text/javascript\">\n";
          print "function func$plotnum() {                                                                                                                                                                         
  if(document.getElementById(\"chbx$plotnum\").checked==true){                                                                                                                                                     
     gnuplot.show_plot(\"jsoutput_3_plot_$plotnum\");                                                                                                                                                              
   } else {                                                                                                                                                                                                        
     gnuplot.hide_plot(\"jsoutput_3_plot_$plotnum\");                                                                                                                                                              
   }                                                                                                                                                                                                               
  }; </script>\n";
                    my $fit_file = "multi_state_model_".$state_number."_1_1.dat";
                    print " show/hide <a href = \"$fit_file\"> weighted profile </a> </b> </th></tr><tr><td>";

                    print "<table align=center> <tr>";
          # read and display PDBs                                                                                                                                                                                  
                    for(my $i=0; $i<$state_number; $i++) {
                        my $curr_state = $i+1;
                        my $fileName = "e" . $state_number . "/e" . $model_number ."_" . $i . ".pdb";
                        my $newFileName = "e" . $state_number . "_" . $model_number . "_" . $i . ".pdb";
                        `grep CA $fileName > $newFileName`;
                        `grep \" P \" $fileName >> $newFileName`;
            #`$home/rg $fileName >& rg_tmp.out`;                                                                                                                                                                   
                        my $rg = `head -n\$curr_state rg\$state_number | tail -n1`; #`grep Rg rg_tmp.out | awk '{print \$3}'`;                                                                                                 
                        chomp $rg; #chop $rg; chop $rg;                                                                                                                                                                        
                        my @wtmp = split(' ', $tmp[1]);
                        my $weight = $wtmp[0];
                        my $num = $i+1;

                        print "<td><table><tr><th><b>PDB$num: $fileName R<sub>g</sub> = $rg w<sub>$num</sub> = $weight</b></th></tr><tr><td>\n";
                        print "<div  id=\"wrapper2\">\n";
                        print "<script type=\"text/javascript\">\n";
                        my $appletName = "myJmol".$state_number."_".$i;
                        print "$appletName = Jmol.getApplet(\"$appletName\", myInfo1);\n";
                        print "Jmol.script($appletName, 'load \"/foxs/runs/$dirname/$newFileName\";backbone OFF; cartoons; color $color;' );\n";
                        print "</script></div></td></tr></table> </td>\n";
                    }

                    print "</tr> </table> </td></tr>\n";
                    last;
                }
            }
        }
    }
}




sub trimExtension {
  my $str = shift;
  $str =~ s/\.[^.]+$//;
  return $str;
}




