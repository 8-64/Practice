#!/usr/bin/perl

use v5.26;
use warnings;
use experimental 'signatures';

# Find the maximum number of edges you can remove from the tree to get a forest
# such that each connected component of the forest contains an even number of nodes.
package Graph {
  use Data::Dumper 'Dumper';
  $Data::Dumper::Terse = 1;
  sub new ($class, $id) {
    bless {
      children => [],
      id => $id,
    }, $class;
  }

  sub add ($self, $id, $parent) {
    if ($self->{id} == $parent) {
      push ($self->{children}->@*, Graph->new($id));
      return $self;
    }

    foreach my $child ($self->{children}->@*) {
      $child->add($id, $parent);
    }
  }

  sub evenForest ($self) {
    my $total = 0;
    foreach my $child ($self->{children}->@*) {
      ++$total unless ($child->countNodes % 2);
      $total += $child->evenForest();
    }
    return $total;
  }

  sub countNodes ($self) {
    my $c = 1;
    foreach my $child ($self->{children}->@*) {
      $c += $child->countNodes;
    }
    return $c;
  }

  sub dump ($self) {
    say Dumper ($self);
  }
}

my (undef, $n) = &GetIntList;
my $graph = Graph->new(1);
$graph->add(&GetIntList) while $n--;
say $graph->evenForest();

sub GetIntList { map { int } split(/\s+/n, <STDIN>) }
