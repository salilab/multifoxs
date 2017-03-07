#!/usr/bin/perl -w

use strict;
use FindBin;

if ($#ARGV != 1) {
  print "getMinMaxScore.pl <output file name> <last result>\n";
  exit;
}

my $resFileName = $ARGV[0];
my $last = $ARGV[1];

open(DATA, $resFileName);

my $firstScore = 0;
my $lastScore = 0;

my $modelNum = 0;
my $numberOfStates = 0;

while(<DATA>) {
  chomp;
  if (index($_, "x1") != -1) {
    my @tmp=split('\|',$_);
    if ($#tmp>0 and $tmp[0] =~/\d/) {
      $modelNum=int $tmp[0];
      if ($firstScore == 0) { $firstScore = $tmp[1]; }
      if ($modelNum > $last) { last; }
      $lastScore = $tmp[1];
    }
  } else {
      if ($modelNum == 1) { $numberOfStates++; }
  }
}

my $diff = $lastScore - $firstScore;
print "$numberOfStates $firstScore $diff\n";
