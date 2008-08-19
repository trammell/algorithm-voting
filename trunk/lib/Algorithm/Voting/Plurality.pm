# $Id$
# $URL$

package Algorithm::Voting::Plurality;

use strict;
use warnings;
use base 'Class::Accessor::Fast';
use List::Util 'sum';
use Params::Validate 'validate', 'ARRAYREF';
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
    for my $ballot (ballots()) {
        $box->add( $ballot );
    }

    # and print the result of the election
    print $box->result->as_string;

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

=head2 candidates

=cut

sub candidates {
    my $self = shift;
    if ($self->{candidates}) {
        return @{ $self->{candidates} };
    }
    return;
}

=head2 add

=cut

sub add {
    my ($self, $ballot) = @_;
    $self->validate_ballot($ballot);
    $self->increment_tally($ballot->candidate);
    return $self->count;
}

=head2 increment_tally

=cut

sub increment_tally {
    my ($self, $candidate) = @_;
    $self->tally->{$candidate} += 1;
}

=head2 validate_ballot

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

=cut

sub count {
    my $self = shift;
    return sum values %{ $self->tally() };
}

=head2 $obj->result

=cut

sub result {
    my $self = shift;
    my $r = Algorithm::Voting::Result->new(
    	formatter => __PACKAGE__,
	summary => $self->tally,
    );
    return $r;
}

1;

