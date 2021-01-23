#!/usr/bin/perl

use v5.26;
use warnings;
use experimental 'signatures';

use List::Util 'uniq';

# Given 3 arrays of different sizes, find the number of such distinct triplets
# that elements from first and third array are <= elements from the second one

sub triplets {
    my @first  = sort { $a <=> $b } uniq &GetIntList;
    my @second = sort { $a <=> $b } uniq &GetIntList;
    my @third  = sort { $a <=> $b } uniq &GetIntList;

    my $total = 0;
    foreach my $el (@second) {
        my $fp = bin_find(\@first, $el);
        next if ($fp == -1);
        my $tp = bin_find(\@third, $el);
        next if ($tp == -1);
        $total += ($fp + 1) * ($tp + 1);
    }
    $total;
}

<STDIN>; # Skip first
say &triplets;

sub GetIntList { map { int } split(/\s+/n, <STDIN>) }

# Find a position in the array that is larger than n
sub bin_find ($array, $n) {
    my ($start, $end) = (0, $#$array);
    my ($mid, $comp) = (0, 0);
    while ($start < $end) {
        $mid = int(($start + $end)/2);
        $comp = $array->[$mid] <=> $n;
        if    ($comp == -1) { $start = $mid + 1 }
        elsif ($comp == 1)  { $end = $mid }
        else                { last }
    }

    # Correction, if needed
    {
        if ($array->[$mid] > $n) { $mid--; ($mid < 1) ? last : redo }
        if (exists ($array->[$mid+1]) and $array->[$mid+1] <= $n) { $mid++; redo }
    }
    return $mid;
}

__DATA__
4 3 4
1 3 5 7
5 7 9
7 9 11 13
