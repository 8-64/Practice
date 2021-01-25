#!/usr/bin/perl

# Sort log file by size of responses, ascending; save memory

use v5.26;
use warnings;
use experimental 'signatures';

my $log_file = 'test_data/apache_log.txt';
my $log_file_sorted = 'test_data/apache_log_sorted.txt';

open (my $LOG, '<', $log_file) or die "Cannot open $log_file - $!";
my $position = 0;
my @file_info;
while (my $line = <$LOG>) {
    my $l = length $line;
    chomp $line;
    $line =~ s/^.+HTTP\/1\.1"\s+[1-5][0-9]{2}\s+//;
    $line =~ m/^(?<Size>[0-9]+)/;
    my $position = (tell $LOG) - $l;
    my $r_size = int($+{Size} // 0);
    push (@file_info, [ $r_size, $position, $l ]);
}

@file_info = sort { $a->[0] <=> $b->[0] } @file_info;

open (my $LOG_SORTED, '>', $log_file_sorted) or die "Cannot open $log_file_sorted - $!";

foreach (@file_info) {
    seek ($LOG, $_->[1], 0);
    my $line;
    read ($LOG, $line, $_->[2]);
    print $LOG_SORTED $line;
}

close $LOG;
close $LOG_SORTED;
