#!/usr/bin/perl

use v5.23;
use feature ':all';
use warnings; no warnings 'experimental';

package UndirectedGraph {
  use Data::Dumper 'Dumper';
  $Data::Dumper::Terse = 1;

  sub new ($class) {
    bless {
      nodes => {},
    }, $class;
  }

  sub enumerate ($self, $upto) {
    foreach (1..$upto) {
      $self->{nodes}->{$_} = {};
    }
    $self;
  }

  # Add an edge
  sub add ($self, $first, $second) {
    $self->{nodes}->{$first}->{$second}++;
    $self->{nodes}->{$second}->{$first}++;
  }

  sub connections ($self, $node) {
    return keys $self->{nodes}->{$node}->%*;
  }

  sub allDistancesFrom ($self, $node, $distance = 1, $distances = {}) {
    my @next;
    foreach my $neighbour ($self->connections($node)) {
      next if (exists $distances->{$neighbour} and $distances->{$neighbour} <= $distance);
      $distances->{$neighbour} = $distance;
      push (@next, $neighbour);
    }
    $self->allDistancesFrom($_, $distance + 1, $distances) foreach @next;

    return $distances;
  }

  sub dump ($self) {
    say Dumper ($self);
  }
}

__END__

=pod

=encoding utf8

=head1 DESCRIPTION

Undirected Graph class implementation.

TODO: some test cases + tests driver.

=head1 USAGE

    my $graph = UndirectedGraph->new->enumerate($n_of_nodes);
    $graph->add($_) foreach @edges;
    $graph->dump;
    my $report = $graph->allDistancesFrom($root);

=cut
