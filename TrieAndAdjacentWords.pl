#!/usr/bin/perl

use v5.23;
use feature ':all';
use warnings; no warnings 'experimental';

package Trie {
    use constant END_MARK => '$';

    sub new ($class) { bless {}, $class }

    # Add a word to the trie
    sub add ($self, $word) {
        my $pointer = \$self;
        foreach my $letter (split('', $word), END_MARK) {
            $pointer = \$$pointer->{$letter};
        }
        $self;
    }

    # Is this word present in the trie?
    # Returns: 1 if Yes, 0 if No
    sub has ($self, $word) {
        return $self->hasPrefix($word . END_MARK);
    }

    # Is this prefix present in the trie?
    # Returns: 1 if Yes, 0 if No
    sub hasPrefix ($self, $word) {
        my $pointer = \$self;
        foreach my $letter (split('', $word)) {
            return 0 unless exists $$pointer->{$letter};
            $pointer = \$$pointer->{$letter};
        }
        return 1;
    }

    1;
} # End of Trie

# Function to analyze the word and find sub-words without any spacing in between
# ACCEPTS
# - Trie object
# - Word
# RETURNS
# - List of matches or an empty list if there are no matches
sub subwords ($trie, $word) {
    my (@matches, $current);
    my $word_length = length $word;

    # Iterate over the string, skipping ahead when the longest subword is found
    for (my ($start, $size) = (0, 1);;) {
        my $part = substr($word, $start, $size);

        if ($trie->hasPrefix($part)) {
            $current = $part;

            if ($start + $size == $word_length) {
                push (@matches, $current);
                last;
            }

            $size++;
        # next potential constituent word
        } elsif (defined $current) {
            push(@matches, $current);
            $current = undef;
            $start += $size - 1;
            $size = 1;
        # no matches - return an empty list
        } else {
            @matches = ();
            last;
        }
    }

    return @matches;
}

#==============================================================================
# Testing it
use Test::More;

my $trie = Trie->new;
$trie->add($_) foreach (qw[foo foot ball]);

ok([ subwords($trie, 'football') ] ~~ ["foot", "ball"], '["foo", "foot", "ball"], "football" -> ["foot", "ball"]');
ok([ subwords($trie, 'butterfly') ] ~~ [], '["foo", "foot", "ball"], "butterfly" -> no match');

ok([ subwords($trie, 'footballfootball') ] ~~ ['foot', 'ball', 'foot', 'ball'], '["foo", "foot", "ball"], "footballfootball" -> ["foot", "ball", "foot", "ball"]');
ok([ subwords($trie, 'footballfoootball') ] ~~ [], '["foo", "foot", "ball"], "["foo", "foot", "ball"], "footballfoootball" -> no match');

my $another_trie = Trie->new;
$another_trie->add($_) foreach (qw[foo ball]);
ok([ subwords($another_trie, 'football') ] ~~ [], '["foo", "ball"], "football" -> no match');

done_testing;

__END__

=pod
    # initially I implemented "two-pointer approach" using block + 2 foreaches
    # but plain "for" is more concise

    my $initial = 0;
    SEARCH: {
        foreach my $start ($initial..($word_length - 1)) {
            foreach my $size (1..($word_length - $start)) {
                my $part = substr($word, $start, $size);

                if ($trie->hasPrefix($part)) {
                    $current = $part;

                    # Check whether it is the end of the analyzed word
                    # if it is, then it's done
                    if ($start + $size == $word_length) {
                        push (@matches, $current);
                        last SEARCH;
                    }
                # there is no such prefix anymore, but previous prefix exists ->
                #   previous prefix is a word, move forward in the string
                } elsif (defined $current) {
                    push (@matches, $current);
                    $current = undef;
                    $initial += $size - 1;
                    redo SEARCH;
                # no matches - return an empty list
                } else {
                    @matches = ();
                    last SEARCH;
                }
            }
        }
    }
=cut
