#!/usr/bin/perl

use v5.23;
use feature ':all';
use warnings; no warnings 'experimental';

use Carp;
use JSON ();
use JSON::PP ();
use List::Util 'min';
use Try::Tiny;

my $data = Decode(&GetData);
my $request = Decode(&GetRequest);
my $responce = Available($data, $request);
@$responce = sort { $a->{price} <=> $b->{price} } @$responce;
# TODO: Duplicates?
say Encode($responce);

exit 0;

sub Available ($data, $request) {
    my $checkin  = $request->{checkin};
    my $checkout = $request->{checkout};
    my @results  = FilterHotels($data->{$checkin}, $request);

    foreach my $day (($checkin + 1)..($checkout - 1)) {
        my $applicables = FilterHotels($data->{$day}, $request);
        my @until_today;
        while (my $result = pop @results) {
            foreach my $block (@$applicables) {
                push(@until_today, MergeRooms($result, $block));
            }
        }
        @results = @until_today;
    }

    wantarray? @results : \@results;
}

sub MergeRooms ($result, $block) {
    $result = { %$result };
    $result->{price}        += $block->{price};
    $result->{availability} = min($result->{availability}, $block->{availability});
    $result->{features}     = MaskToFeatures(FeatureMask($result->{features}->@*) & FeatureMask($block->{features}->@*));
    $result;
}

sub FilterHotels ($on_this_day, $request) {
    my @collection;
    my $wanted = FeatureMask($request->{features}->@*);
    @collection = grep {
            $_->{availability} >= $request->{rooms}
        and (FeatureMask($_->{features}->@*) & $wanted) == $wanted
     } @$on_this_day;
    wantarray? @collection : \@collection;
}

# Use masks to find intersections
INIT {
    my (%seen, %reverse); # lookup closure for both functions
    sub FeatureMask (@features) {
        state $current_bit = 1;
        my $result = 0;
        foreach (@features) {
            unless (exists $seen{$_}) {
                $seen{$_} = $current_bit;
                $reverse{$current_bit} = $_;
                $current_bit <<= 1;
            }
            $result += $seen{$_};
        }
        $result;
    }

    sub MaskToFeatures ($mask) {
        my @features;
        my $power = 1;
        while ($mask > 0) {
            push(@features, $reverse{ $power }) if ($mask & 1);
            $mask >>= 1;
            $power <<= 1;
        }
        wantarray? @features : \@features;
    }
}

# Transform Perlish data structure into JSON
# Generated output is a valid JSON this time
# Of course, it is possible to tinker with it to create a one with bare keys
# Bat that would be way too silly
sub Encode ($data) {
    my $encoder = JSON->new->pretty([1]);
    return $encoder->encode($data);
}

# Supplied sort-of-JSONs may be broken, so care is needed when parsing them
sub Decode ($data) {
    my $result;
    $result = (try {
        my $decoder = JSON->new;
        $decoder->decode($data);
    }) // (try {
        my $decoder = JSON::PP->new->allow_barekey([1])->allow_singlequote([1]);
        $decoder->decode($data);
    }) // croak "Way too malformed JSON to decode!\n";
    return $result;
}

sub GetData {
    return <<~'DOC';
    {
      176: [
        {
          price: 120,
          features: [ 'breakfast', 'refundable' ],
          availability: 5
        }
      ],
      177: [
        {
          price: 120,
          features: [ 'breakfast', 'refundable' ],
          availability: 1
      },
      {
          price: 130,
          features: [ 'wifi', 'breakfast' ],
          availability: 3
      },
      {
          price: 150,
          features: [ 'wifi', 'breakfast', 'refundable' ],
          availability: 7
      }
      ]
    }
    DOC
}

sub GetRequest {
    return <<~'DOC';
    {
      checkin: 176,
      checkout: 178,
      features: [ 'breakfast' ],
      rooms: 1
    }
    DOC
}

__END__

=pod

=head1 TASK

Given a data structure and a search request generate a responce

=cut
