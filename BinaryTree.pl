#!/usr/bin/perl

use v5.23;
use feature ':all';
use warnings; no warnings 'experimental';

package BinTree {
    no warnings 'recursion';
    sub new ($self) { bless {}, $self }

    # add a value to the tree
    sub add ($self, $value) {
        # Check if the node has the value assigned
        if (exists $self->{value}) {
            my $node = BinTree->new->add($value);
            $self->addLeave($node);
        } else {
            $self->{value} = $value;
        }
        return $self;
    }

    # Add another BinTree object to the tree
    sub addLeave ($self, $node) {
        my $direction = ($node->{value} >= $self->{value}) ? 'left' : 'right';
        if (exists $self->{$direction}) {
            $self->{$direction}->addLeave($node);
        } else {
            $self->{$direction} = $node;
        }
        return $self if defined wantarray;
    }

    # Dump the tree contents in requested direction
    sub dump ($self, $from = 'left', $to = 'right', $collection = []) {
        $self->{$from}->dump($from, $to, $collection) if (exists $self->{$from});
        push (@$collection, $self->{value});
        $self->{$to}->dump($from, $to, $collection) if (exists $self->{$to});
        return @$collection if wantarray;
    }
}

#=============================[ TESTING ]=======================================
use Test::More;

my @test = map { int rand 100 } 1..10_000;

my $tree = BinTree->new;
$tree->add($_) foreach @test;

my @ascending_copy  = sort { $a <=> $b } @test;
my @descending_copy = sort { $b <=> $a } @test;

is_deeply([ $tree->dump ], \@descending_copy, 'Is descending binary tree dump same as the sorted test array?');
is_deeply([ $tree->dump(right => 'left') ], \@ascending_copy, 'Is ascending binary tree dump same as the sorted test array?');

done_testing;

__END__

=pod

Hash-based binary tree implementation

For some reason, I was absolutely dreading being asked to implement this thing until the day has finally come :)

=cut
