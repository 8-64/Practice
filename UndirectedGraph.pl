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

  # Add just a node
  sub addNode ($self, $node) {
    $self->{nodes}->{$node} = {};
    $self;
  }

  # Add an edge with weight
  sub addWeighted ($self, $first, $second, $weight) {
    $self->{nodes}->{$first}->{$second}->{weight} = $weight;
    $self->{nodes}->{$second}->{$first}->{weight} = $weight;
  }

  # Get edges applicable for the Prim's algorithm iteration
  sub getEdgesPrimApplicable ($self, $prim_tree) {
      my @edges;
      foreach my $node (keys $prim_tree->{nodes}->%*) {
          foreach my $connection ($self->connections($node)) {
              next if (exists $prim_tree->{nodes}->{$connection});
              push(@edges, [ $node, $connection, $self->{nodes}->{$node}->{$connection}->{weight} ]);
          }
      }
      return undef unless (@edges);
      wantarray? @edges : \@edges;
  }

  # Create a minimal spanning tree from the graph and return it using Prim's algorithm
  sub mst ($self, $starting) {
    my $prim_tree = UndirectedGraph->new->addNode($starting);

    my $edges;
    while ($edges = $self->getEdgesPrimApplicable($prim_tree)) {
      @$edges = sort { $a->[2] <=> $b->[2] } @$edges;
      $prim_tree->addWeighted($edges->[0]->@*);
    }
    $prim_tree;
  }

  sub sumOf ($self, $of) {
    my $sum = 0;
    foreach my $node (keys $self->{nodes}->%*) {
      foreach my $connection ($self->connections($node)) {
        $sum += $self->{nodes}->{$node}->{$connection}->{$of};
      }
    }
    $sum /= 2;
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

    my $mst = $graph->mst($starting);
    say $mst->sumOf('weight');

=cut
