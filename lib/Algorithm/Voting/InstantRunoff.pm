# $Id$
# $URL$

package Algorithm::Voting::InstantRunoff;

use strict;
use warnings;
use base 'Class::Accessor::Fast';
use List::Util 'sum';
use Params::Validate qw/ validate validate_pos ARRAYREF /;

__PACKAGE__->mk_accessors(qw/ tally /);

=pod

=head1 NAME

Algorithm::Voting::InstantRunoff - implement instant runoff voting

=head1 SYNOPSIS

    # construct a "ballot box"
    use Algorithm::Voting::Ballot;
    use Algorithm::Voting::InstantRunoff;
    my $box = Algorithm::Voting::InstantRunoff->new();

    # add ballots to the box
    $box->add( Algorithm::Voting::Ballot->new('Ralph') );
    $box->add( Algorithm::Voting::Ballot->new('Fred') );
    # ... 
    $box->add( Algorithm::Voting::Ballot->new('Ralph') );

    # and print the result
    print $box->as_string;

=head1 DESCRIPTION

From L<http://en.wikipedia.org/wiki/Instant_runoff_voting>:

=over 4

Instant-runoff voting (IRV) is a voting system used for single-winner elections
in which voters have one vote and rank candidates in order of preference. If no
candidate receives a majority of first preference rankings, the candidate with
the fewest number of votes is eliminated and that candidate's votes
redistributed to the voters' next preferences among the remaining candidates.
This process is repeated until one candidate has a majority of votes among
candidates not eliminated. The term "instant runoff" is used because IRV is
said to simulate a series of run-off elections tallied in rounds, as in an
exhaustive ballot election.

=back

=head1 METHODS

=head2 Algorithm::Voting::InstantRunoff->new(%args)

=cut

sub new {
    my $class = shift;
    my %valid = (
        candidates => {
            type     => ARRAYREF,
            optional => 1,
        },
    );
    my %args = validate(@_, \%valid);
    my $self = bless \%args, $class;
    $self->tally({});
    return $self;
}

=head2 $box->candidates

Returns a list containing the candidate names used in the construction of the
ballot box.  If no candidates were specified at construction of the box, the
empty list is returned.

=cut

sub candidates {
    my $self = shift;
    return @{ $self->{candidates} || [] };
}

=head2 $box->add($ballot)

Add C<$ballot> to the box.  C<$ballot> can be any object that we can call
method C<candidate()> on.

=cut

# FIXME
sub add {
    my $self = shift;
    my %valid = ( can => [ 'candidate' ], );
    my ($ballot) = validate_pos(@_, \%valid);
    $self->validate_ballot($ballot);
    $self->increment_tally($ballot->candidate);
    return $self->count;
}

=head2 $box->increment_tally($candidate)

Increments the tally for C<$candidate> by 1.

=cut

sub increment_tally {
    my ($self, $candidate) = @_;
    $self->tally->{$candidate} += 1;
    return $self->tally->{$candidate};
}

=head2 $box->validate_ballot($ballot)

If this election is limited to a specific list of candidates, this method will
C<die()> if the candidate on C<$ballot> is not one of them.

=cut

sub validate_ballot {
    my ($self, $ballot) = @_;
    # if this ballot box has a list of "valid" candidates, verify that the
    # candidate on this ballot is one of them.
    if ($self->candidates) {
        unless (grep { $_ eq $ballot->candidate } $self->candidates) {
            die "Invalid ballot: candidate '@{[ $ballot->candidate ]}'",
                " is not on the candidate list";
        }
    }
}

=head2 count

Returns the total number of ballots cast so far.

=cut

sub count {
    my $self = shift;
    return sum values %{ $self->tally() };
}

=head2 result

The result is a "digested" version of the ballot tally, ordered by the number
of ballots cast for a candidate.

This method returns a list of arrayrefs, each of the form C<[$n, @candidates]>,
and sorted by decreasing C<$n>.  Candidates "tied" with the same number of
votes are lumped together.

For example, an election with three candidates A, B, and C, getting 100, 200,
and 100 votes respectively, would generate a result structure like this:

    [
        [ 200, "B" ],
        [ 100, "A", "C" ],
    ]

=cut

sub result {
    my $self = shift;
    # %rev is a "reverse" hash, in the sense that the key is the number of
    # votes, and the value is an arrayref containing the candidates who got
    # that number of votes.
    my %rev;
    foreach my $cand (keys %{ $self->tally }) {
        my $votes = $self->tally->{$cand};
        push @{ $rev{$votes} }, $cand;
    }
    return
        map { [ $_, @{$rev{$_}} ] }
        sort { $b <=> $a } keys %rev;
}

=head2 $box->as_string

Returns a string summarizing the election results.

=cut

sub as_string {
    my $self = shift;
    my $pos = 0;
    my $count = $self->count;
    my $string;
    foreach my $r ($self->result) {
        $pos++;
        my ($n, @cand) = @$r;
        my $pct = sprintf '%.2f%%', 100 * $n / $count;
        $string .= sprintf "%3d: ", $pos;
        $string .= "@cand, $n votes ($pct)\n";
    }
    return $string;
}

1;

