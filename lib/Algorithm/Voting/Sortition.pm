
package Algorithm::Voting::Sortition;

use strict;
use warnings;
use Scalar::Util 'reftype';
use Digest::MD5 'md5_hex';
use Math::BigInt;
use Params::Validate 'validate';

=pod

=head1 NAME

Algorithm::Voting::Sortition - implements RFC 3797, "Publicly Verifiable
Nominations Committee (NomCom) Random Selection"

=head1 SYNOPSIS

    use Algorithm::Voting::Sortition;
    my @cand = qw/ fred wilma barney betty /;
    my $box = Algorithm::Voting::Sortition->new(candidates => \@cand);
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
    my %valid = (
        candidates => 1,
        n          => { default => -1 },
        source     => 0,
        keystring  => 0,
    );
    my %args = validate(@_, \%valid);
    return bless \%args, $class;
}

=head2 $obj->candidates

Returns a list containing the current candidates.

=cut

sub candidates {
    return @{ $_[0]->{candidates} };
}

=head2 $obj->keystring([@source])

Stringify elements of C<@source> to create a master "key string".

=cut

sub keystring {
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

=head2 $obj->seq

Generates a sequence of integers based on the MD5 sum of the key.  These
integers are used to choose the winners from the candidate pool.

=cut

sub seq {
    my $self = shift;
    my $n = ($self->{n} < 1) ? scalar($self->candidates) : $self->{n};
    map {
        my $p = $self->prefix($_);
        my $hex = md5_hex($p . $self->keystring . $p);
        my $bi = Math::Bigint->new("0x${hex}");
    } 1 .. $n;
}

sub prefix {
    my ($self,$n) = @_;
    return pack("n",$n);  # little-endian, 2-byte ("short int")
}

=head2 $obj->result

Returns the data structure containing the contest results.

=cut

sub result {
    my $self = shift;
    my @c = $self->candidates;
    for my $i ($self->seq) {
        my $choice = $i


    }

    return;
}

=head2 $obj->as_string

Delegates formatting to class C<< $obj->formatter >>.

=cut

sub as_string {
    my $self = shift;
    

}

1;

