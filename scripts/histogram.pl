#!/usr/bin/perl -w

use strict;

if ($#ARGV != 0) {
  print "histogram.pl <interval>\n";
  exit;
}

my $interval = $ARGV[0];

# read input values
my @values;
my @weights;
my $counter=0;
my $total_weight=0.0;
while(<STDIN>) {
    chomp;
  my @tmp=split(' ',$_);
  my $val = $tmp[0];
  my $weight = 1.0;
  if ($#tmp > 0) { $weight = $tmp[1]; }
  #print "$_ $val $weight\n";
  $counter++;
  $total_weight+=$weight;
  if($val >= 0) {
    push(@values, $val);
    push(@weights, $weight);
  }
}

#print "total $counter\n";
my $total = $counter;

# sort them
my @sorted = sort { $a <=> $b } @values;

my $first = $sorted[0];
my $last = $sorted[$#sorted];
my $numberOfBins = ($last-$first)/$interval + 1;
print "First = $first Last = $last bins = $numberOfBins Total = $total WeightSum = $total_weight\n";

# compute histogram
my @hist = (0) x $numberOfBins; # init with zeros

for my $i (0..$total-1) {
  my $val = $values[$i];
  my $binNumber = int (($val-$first)/$interval);
  $hist[$binNumber] += $weights[$i];
}

my $zero_bin = $first - $interval;
print "$zero_bin 0 0 0 \n";
for my $i (0..$numberOfBins-1) {
  my $rg_bin = ($i*$interval) + $first;
  my $fraction = $hist[$i]/$total_weight;
  #if($fraction > 0.01) {
    print "$rg_bin $fraction $i $hist[$i] \n";
  #} else {
  #  print "$rg_bin 0 0 0\n";
  #}
}
my $last_bin = $first + $numberOfBins*$interval;
print "$last_bin 0 0 0 \n";
