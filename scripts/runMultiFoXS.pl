#!/usr/bin/perl -w

use strict;
use FindBin;
use Getopt::Long;

if($#ARGV < 4) {
  print "runMultiFoXS.pl <input_pdb> <flexible_residues_file> <saxs_file> <connect_rigid_bodies_file> <number_of_models>\n";
  exit;
}

# software directories, please update to your path!
my $home = "$FindBin::Bin";

my $pdb = $ARGV[0];
my $hinge_file = $ARGV[1];
my $saxs_file = $ARGV[2];     # SAXS profile

my $connect_rigid_bodies_file = $ARGV[3];
if($connect_rigid_bodies_file eq "-") { $connect_rigid_bodies_file = ""; }

my $modelsnum = 100;
if($#ARGV > 3) { $modelsnum = $ARGV[4]; }

# TODO: validate that all files exist
my $cmd;

# SAXS profile
$cmd = "validate_profile $saxs_file > v.out";
print "$cmd\n";
`$cmd`;
my $profile_size = 0;
if (-s "v.out") {
  $profile_size = `grep size v.out | awk '{print \$8}'` + 0;
}
if($profile_size < 10) {
  print "ERROR: Invalid input profile file $saxs_file\n";
  exit;
} else {
  print "Input profile size is $profile_size\n";
}

# STEP 1: run RRT sample
my $iteration_number = 10*$modelsnum;
$cmd = "rrt_sample $pdb $hinge_file -i $iteration_number -n $modelsnum -s 0.3";
if(length $connect_rigid_bodies_file > 0) {
  $cmd .= " -c $connect_rigid_bodies_file";
}
my $flexresnum = `cat $hinge_file | wc -l`;
chomp $flexresnum;
if($flexresnum > 15) { $cmd .= " -a 10"; }
print "$cmd\n";
`$cmd`;
if(not -e "nodes1.pdb") {
  print "ERROR: RRT generated no conformations\n";
  exit;
}


# STEP 2: run FoXS
for(my $i = 1; $i < 110; $i++) {
  my $nodes_file = "nodes".$i.".pdb";
  if(-e $nodes_file) {
    $cmd = "foxs -m 2 -p $nodes_file";
    print "$cmd\n";
    `$cmd`;
  }
} 
# run FoXS for input PDB
$cmd = "foxs $saxs_file $pdb -j";
print "$cmd\n"; 
`$cmd`;     

# STEP 3: run MultiFoXS
`ls nodes*.pdb.dat > filenames`;
$cmd = "multi_foxs $saxs_file filenames -s 5 -k 1000 --max_c2 4.0";
print "$cmd\n";
`$cmd`;


# STEP 4: calculate Rg
`rm -f rg.out; touch rg.out`;
for(my $i = 1; $i < 110; $i++) {
  my $nodes_file = "nodes".$i.".pdb";
  if(-e $nodes_file) {
    $cmd = "rg -m 2 $nodes_file >> rg.out";
    print "$cmd\n";
    `$cmd`;
  }
}
`grep Rg rg.out | awk '{ print \$3}' > rg`;

# STEP 5: plots
`$home/plotHistograms.pl 5 100 1 1`;

`rm -f e?/e[2-9]?_?.pdb e?/e1[1-9]_?.pdb`;
`zip conformations.zip nodes*.pdb`;
`zip -r multi_foxs.zip ensembles_size_?.txt multi_state_model_?_1_1.dat e? chis  chis.png  gnuplot.txt  hist  hist? hist.png  plotbar.plt`;
`rm -f nodes*.pdb.dat`;
`rm -f nodes?.pdb nodes??.pdb nodes???.pdb`;
