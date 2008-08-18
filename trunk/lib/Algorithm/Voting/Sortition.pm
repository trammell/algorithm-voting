
package Algorithm::Voting::Sortition;

use strict;
use warnings;
use Scalar::Util 'reftype';
use Digest::MD5 'md5_hex';
use bigint;

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
    my $class = shift;
    bless {}, $class;
}

=head2 $obj->make_key(@source)

Stringify elements of C<@source> to create a master key.

=cut

sub make_key {
    my ($self, @source) = @_;
    my $key;
    for my $s (@source) {
        if (reftype($s) && reftype($s) eq 'ARRAY') {
            $key .= $self->_compound_key(@$s);
        }
        else {
            $key .= "$s./";
        }
    }
    return $key;
}

sub _compound_key {
    my ($self, @source) = @_;
    @source = sort { $a <=> $b } @source;
    my $key;
    $key .= "$_." for @source;
    return "$key/";
}

sub results {

    Algorithm::Voting::Result->new()


}

1;

