#!/usr/bin/perl

use v5.23;
use feature ':all';
use warnings; no warnings 'experimental';
use utf8;

use Carp;

*MyCWD = Internals->can('getcwd') // do { require Cwd; Cwd->can('getcwd') };

given (scalar @ARGV) {
    # no arguments -> print one line from one random file in the current directory
    when (0) { say &GetLineFrom(&GetRandomTextFile(&MyCWD)) }

    # 1 and looks like a number -> print that many lines from random files
    when ($_ == 1 and $ARGV[0] =~ /^-{0,}[0-9]+$/) {
        foreach my $file (&GetRandomTextFile(&MyCWD, abs int $ARGV[0])) {
            say &GetLineFrom($file);
        }
    }

    # 1 and is a file -> print one line from it
    when ($_ == 1 and -r -e $ARGV[0]) { say &GetLineFrom($ARGV[0]); say scalar @ARGV }

    # 2 -> first should be a file, second - number of lines
    when ($_ == 2 and -r -e $ARGV[0] and $ARGV[1] =~ /^-{0,}[0-9]+$/) {
        my $n = abs int $ARGV[1];
        say &GetLineFrom($ARGV[0]) while $n--;
    }

    default { die ("Can't understand arguments - [@ARGV]\n") }
}

sub GetLineFrom ($file) {
    open(my $FH, '<', $file) or croak("Can't open the file [$file] - [$!]");
    seek($FH, rand -s $file, 0);
    {
        my $position = tell $FH;
        read ($FH, my $char, 1);
        if ($char !~ /[\r\n]/ and $position > 0) {
            seek($FH, -(length($char) + 1), 1);
            redo;
        }
    }

    my $line = &Trim(scalar readline $FH);
    close $FH;
    return $line;
}

sub GetRandomTextFile ($dir, $n = 1) {
    opendir(my $DH, $dir) or croak("Can't open the dir [$dir] - [$!]");
    my @files = grep { -r -s -T $_ } grep { $_ !~ /^(\.){1,2}$/ } readdir $DH;
    closedir $DH;
    my @randoms;
    push(@randoms, $dir . '/' . $files[rand @files]) while $n--;
    return @randoms;
}

sub Trim ($str) { $str =~ s/(^\s+)|(\s+$)//gn; $str }

__END__

=pod

=encoding utf8

=head1 DESCRIPTION

Print a random line (from a random file)

=head1 USAGE


=cut
