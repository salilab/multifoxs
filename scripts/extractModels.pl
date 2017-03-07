#!/usr/bin/perl -w

use strict;
use File::Basename;

if($#ARGV < 1) {
  print "Usage: extractModels.pl <PDB file name> <model_num1> <model_num2>...\n";
  exit(0);
}

my $dir = ".";
if($ARGV[0] =~ /(.*)\/([^\/]*)$/) {
  $dir = $1;
}

my $pdbCode = basename($ARGV[0]);
#trim ".pdb" extension if exists
my @tmp=split('\.',$pdbCode);
if($tmp[$#tmp] =~ /^pdb$/i && $#tmp==1) {
  $pdbCode = $tmp[0];
}

print "$pdbCode\n";

my $model_counter = 1;
open IN_PDB_FILE, $ARGV[0];
while(my $line=<IN_PDB_FILE>) {
  if ($line =~ /^MODEL/) {
    #print "model line = $line \n";
    #$line =~ /MODEL[ ]*([0-9]*)[ ]*([a-zA-Z0-9]*)/;
    #my $model_index = $1;
    for(my $i=1; $i<$#ARGV+1; $i++) {
      if($ARGV[$i] == $model_counter) { # by index in file only
        open OUT_MODEL, ">$dir/$pdbCode\_m$ARGV[$i].pdb";
        print OUT_MODEL "$line";
        while (!($line =~ /^ENDMDL/)) {
          $line = <IN_PDB_FILE>;
          print OUT_MODEL "$line";
        }
        close OUT_MODEL;
      }
    }
    $model_counter++;
  }
}

close IN_PDB_FILE;
