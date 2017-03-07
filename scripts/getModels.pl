#!/usr/bin/perl -w

use strict;
use FindBin;
use File::Basename;

if ($#ARGV != 1 and $#ARGV !=2 and $#ARGV !=3) {
  print "getModels.pl <output file name> <first result> [last result]\n";
  exit;
}

my $resFileName = $ARGV[0];
my $first = $ARGV[1];
my $last = $first;

if ($#ARGV > 1) {
  $last = $ARGV[2];
}

open(DATA, $resFileName);

my $home = "$FindBin::Bin";

my $inModel = 0;
my $currModelNum = 0;
my $structureCounter = 0;
while(<DATA>) {
  chomp;
  if (index($_, "x1") != -1) {
    my @tmp=split('\|',$_);
    if ($#tmp>0 and $tmp[0] =~/\d/) {
      my $modelNum=int $tmp[0];
      #print "Model num $modelNum\n";
      if ($modelNum >= $first and $modelNum <= $last) {
        $inModel = 1;
        $currModelNum = $modelNum;
        $structureCounter = 0;
      } else {
        $inModel = 0;
      }
    }
  } else {
    if ($inModel) {
      my @tmp = split('\|', $_);
      my @tmp2 = split(' ', $tmp[$#tmp]);
      my $node = $tmp2[0];
      # remove ".dat"
      my $fileName = trimExtension($node);

      my $newFileName = "e" . $currModelNum . "_" . $structureCounter . ".pdb";

      if($node =~ /(\S+)_m(\d+)./g) { # multi model PDB
        #print "Multi model PDB $1 $2\n";
        my $mNum = $2;
        my $nodePdb = $1 . ".pdb";
        `$home/extractModels.pl $nodePdb $mNum\n`;
        if(not -e $fileName) {
          $fileName = $nodePdb . ".m" . "$mNum" . ".pdb";
        }
        `mv $fileName $newFileName`;
      } else {
        # single structure PDB - need better test here
        # my $modelNum = `grep MODEL $fileName | wc -l`;
        # chomp $modelNum;
        # print "Model num = $modelNum\n";
        #print "PDB $fileName $newFileName\n";
        `cp $fileName $newFileName`;
      }

      `rg $newFileName >& rg_tmp.out`;
      my $rg = `grep Rg rg_tmp.out | awk '{print \$3}'`;
      chomp $rg;
      my $weight = 0;
      for(my $i = 1; $i < $#tmp; $i++) {
        my @wtmp = split(' ', $tmp[$i]);
        $weight += $wtmp[0];
        #$weight = substr $weight, 1, -1;
      }
      $weight /= ($#tmp-1);
      print "$rg $weight\n";
      $structureCounter++;
    }
  }
}

sub trimExtension {
  my $str = shift;
  $str =~ s/\.[^.]+$//;
  return $str;
}
