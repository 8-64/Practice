#!/usr/bin/perl

use v5.23;
use feature ':all';
use warnings; no warnings 'experimental';

package Graph {
  sub new ($class) { bless { nodes => {}, }, $class }

  sub nodes ($self) { keys $self->{nodes}->%* }

  sub enumerate ($self, $from, $upto) {
    foreach ($from..$upto) {
      $self->{nodes}->{$_} = {};
    }
    $self;
  }

  # Add a bidirectional edge
  sub add ($self, $first, $second) {
    $self->{nodes}->{$first}->{$second}++;
    $self->{nodes}->{$second}->{$first}++;
  }

  # Add a unidirected edge
  sub addDirected ($self, $first, $second) {
    $self->{nodes}->{$first}->{$second}++;
  }

  sub nodesWithBranches ($self) {
      my @nodes;
      foreach my $node (keys $self->{nodes}->%*) {
          next if ($self->connections($node) < 2);
          push @nodes, $node;
      }
      @nodes;
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

  sub distanceToSelf ($self, $node) {
    my $distances = $self->allDistancesFrom($node);
    return undef unless (exists $distances->{$node});
    return $distances->{$node};
  }
}

#==============================================================================
use List::Util 'min';

my $graph = Graph->new;
$graph->enumerate('A', 'D');
$graph->addDirected(@$_) foreach(
    [A => 'B'],
    [B => 'C'],
    [C => 'D'],
    [D => 'A'],
    [D => 'B'],
);

# Assumption here is that nodes that have branching paths from them could be
# part of multiple paths.
my @branching = $graph->nodesWithBranches;
@branching = $graph->nodes unless (@branching); # case when there are no branching paths
my @cycles;

foreach my $node (@branching) {
    push @cycles, $graph->distanceToSelf($node);
}

say 'Shortest detected cycle has the length of: ', min(@cycles);

__END__

=pod

    Find a shortest cycle in a graph

    Example:

    A --→ B
    ↑   ↗ |
    |  /  |
    | /   ↓
    D ←-- C

=cut
