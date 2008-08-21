# $Id$
# $URL$

package Algorithm::Voting::Plurality;

use strict;
use warnings;
use base 'Class::Accessor::Fast';
use List::Util 'sum';
use Params::Validate qw/ validate validate_pos ARRAYREF /;
use Algorithm::Voting::Result;

__PACKAGE__->mk_accessors(qw/ tally /);

=pod

=head1 NAME

Algorithm::Voting::Plurality - use "Plurality" to decide the sole winner

=head1 SYNOPSIS

    # construct the "ballot box"
    use Algorithm::Voting::Plurality;
    my $box = Algorithm::Voting::Plurality->new();

    # add ballots to the box
    for my $ballot (get_ballot()) {
        $box->add( $ballot );
    }

    # and print the result of the election
    print $box->as_string;

=head1 DESCRIPTION

From L<http://en.wikipedia.org/wiki/Plurality_voting_system>:

=over 4

The plurality voting system is a single-winner voting system often used to
elect executive officers or to elect members of a legislative assembly which is
based on single-member constituencies.

The most common system, used in Canada, India, the UK, and the USA, is simple
plurality, first past the post or winner-takes-all, a voting system in which a
single winner is chosen in a given constituency by having more votes than any
other individual representative.

=back

And from L<http://en.wikipedia.org/wiki/Plurality>:

=over 4

In voting, a plurality vote is the largest number of votes to be given any
candidate or proposition when three or more choices are possible. The candidate
or proposition receiving the largest number of votes has a plurality. The
concept of "plurality" in voting can be contrasted with the concept of
"majority". Majority is "more than half". Combining these two concepts in a
sentence makes it clearer, "A plurality of votes is a total vote received by a
candidate greater than that received by any opponent but less than a majority
of the vote."

=back

=head1 METHODS

=head2 Algorithm::Voting::Plurality->new()

Constructs a "ballot box" object that will use the Plurality criterion to
decide the winner.

Example:

    # construct a ballot box that accepts only three candidates
    my @c = qw( John Barack Ralph );
    my $box = Algorithm::Voting::Plurality->new(candidates => \@c);

=cut

sub new {
    my $class = shift;
    my %valid = (
        candidates => { type => ARRAYREF, optional => 1 },
    );
    my %args = validate(@_, \%valid);
    my $self = bless \%args, $class;
    $self->tally({});
    return $self;
}

=head2 $box->candidates

Returns a list containing the candidate names used in the construction of the
ballot box.

=cut

sub candidates {
    my $self = shift;
    if ($self->{candidates}) {
        return @{ $self->{candidates} };
    }
    return;
}

=head2 $box->add($ballot)

C<$ballot> can be any object that we can call method C<candidate()> on.

=cut

sub add {
    my $self = shift;
    my %valid = (
        can => [ 'candidate' ],
    );
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
}

=head2 $box->validate_ballot($ballot)

If this election is limited to a list of valid candidates, this method will
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

Returns a list of arrayrefs of the form C<< [ @candidates, $n ] >> where
C<@candidates> is a list of candidates, and C<$n> is the number of ballots
cast.

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

Returns a string containing the election results.

=cut

sub as_string {
    my $self = shift;
    my $pos = 1;
    my $count = $self->count;
    my $string;
    foreach my $r ($self->result) {
        my ($n, @cand) = @$r;
        my $pct = sprintf '%.2f%%', 100 * $n / $count;
        $string .= sprintf "%3d: ", $pos;
        $string .= "@cand, $n votes ($pct)\n";
	$pos++;
    }
    return $string;
}

1;

