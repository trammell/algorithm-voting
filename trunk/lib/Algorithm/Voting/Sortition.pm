
package Algorithm::Voting::Sortition;

use Scalar::Util 'reftype';

=pod

=head1 NAME

Algorithm::Voting::Sortition - implements RFC 3797, "Publicly Verifiable
Nominations Committee (NomCom) Random Selection"

=head1 SYNOPSIS

    use Algorithm::Voting::Sortition;
    my @c = qw/ fred wilma pebbles barney betty bamm-bamm /;
    my $box = Algorithm::Voting::Sortition->new(candidates = \@c);
    my @keysrc = (
        [32,40,43,49,53,21],    # powerball numbers on 9 Aug 2008
        11,                     # number of gold medals Phelps has won
        "W 4-1",                # score of Twins game on 8 Aug 2008
    );
    my $key = $box->make_key(@keysrc)
    print "Using key: '$key'\n";
    print $box->result($key)->as_string;

=head1 DESCRIPTION

This package implements the Sortition algorithm as described in RFC 3797,
"Publicly Verifiable Nominations Committee (NomCom) Random Selection"
(L<http://tools.ietf.org/html/rfc3797>):

=over 4

This document describes a method for making random selections in such a way
that the unbiased nature of the choice is publicly verifiable.  As an example,
the selection of the voting members of the IETF Nominations Committee (NomCom)
from the pool of eligible volunteers is used.  Similar techniques would be
applicable to other cases.

=back

=head1 METHODS

=head2 Algorithm::Voting::Sortition->new()

=cut

sub new {



}

sub make_key {
    my $self = shift;
    my @key;
    for $k in (@_) {
        if (reftype($k) eq 'ARRAY') {
            $key .= @$k;
        }
    }
    return join q(/), @key;
}

