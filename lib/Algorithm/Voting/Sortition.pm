# $Id$
# $URL$

package Algorithm::Voting::Sortition;

use strict;
use warnings;
use Scalar::Util qw/reftype looks_like_number/;
use Digest::MD5;
use Math::BigInt;
use Params::Validate 'validate';
use base 'Class::Accessor::Fast';

=pod

=head1 NAME

Algorithm::Voting::Sortition - implements RFC 3797, "Publicly Verifiable
Nominations Committee (NomCom) Random Selection"

=head1 SYNOPSIS

To choose two of our favorite Flintstones pals via sortition:

    use Algorithm::Voting::Sortition;

    # choose a list of candidates
    my @candidates = qw/ fred wilma barney betty pebbles bamm-bamm /;

    # the results of our predetermined entropy source
    my @keysource = (
        [32,40,43,49,53,21],  # 8/9/08 powerball numbers
        "W 4-1",              # final score of 8/8/08 Twins game
    );

    # use sortition to determine the winners
    my $race = Algorithm::Voting::Sortition->new(
        candidates => \@candidates,
        source     => \@keysource,
        n          => 2,
    );
    printf "Key string is: '%s'\n", $race->keystring;
    print $race->as_string;

=head1 DESCRIPTION

Sortition is an unbiased method for "drawing straws" or "casting lots".  This
package implements the Sortition algorithm as described in RFC 3797, "Publicly
Verifiable Nominations Committee (NomCom) Random Selection"
(L<http://tools.ietf.org/html/rfc3797>):

=over 4

This document describes a method for making random selections in such a way
that the unbiased nature of the choice is publicly verifiable.  As an example,
the selection of the voting members of the IETF Nominations Committee (NomCom)
from the pool of eligible volunteers is used.  Similar techniques would be
applicable to other cases.

=back

The elements of sortition are:

=over 4

=item 1. a list of candidates

The ordering of the candidates is important, since a large number modulo the
number of candidates will be used to choose a candidate.

=item 2. a source of entropy

This source of randomness is used to seed the digest function.  Common sources
include lottery numbers and sports scores.

=item 3. a marshalling algorithm

The entropy sources must be combined
The method for combining the seed
elements in the digest

=item 4. a digest function

This module follows RFC 3797 and uses an MD5 digest to combine the entropy seed
and choose winners.  Other digests are suitable.

=back

Once the participants agree on all the sortition elements,

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
        formatter  => { default => __PACKAGE__ },
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

=head2 $obj->n

Returns the number of candidates that are to be chosen from the master list.
If C<n> is unspecified when the sortition object is constructed, the total
number of candidates is used, i.e. the sortition will return a list containing
all candidates.

=cut

sub n {
    my $self = shift;
    if ($self->{n} < 1) {
        $self->{n} = scalar($self->candidates);
    }
    return $self->{n};
}

=head2 $obj->source()

Mutates the entropy source to be used in the sortition.

Example:

    $obj->source(@entropy); # sets the entropy value
    my @e = $obj->source;   # retrieves the entropy

=cut

sub source {
    my $self = shift;
    if (@_) { $self->{source} = \@_; }
    return @{ $self->{source} };
}

=head2 $obj->keystring()

Uses the current value of C<< $self->source >> to create and cache a master
"key string".

=cut

sub keystring {
    my $self = shift;
    unless (exists $self->{keystring}) {
        $self->{keystring} = $self->make_keystring($self->source);
    }
    return $self->{keystring};
}

=head2 $obj->make_keystring(@source)

Creates a "key string" from the input values in C<@source>.

=cut

sub make_keystring {
    my ($self,@source) = @_;
    return join q(), map { $self->stringify($_) . q(/) } @source;
}

=head2 $obj->stringify($thing)

Comverts C<$thing> into a string.

=cut

# XXX needs detail

sub stringify {
    my ($self, $thing) = @_;
    if (reftype($thing)) {
        if (reftype($thing) eq 'ARRAY') {
            return join q(), map { "$_." } $self->_sort(@$thing);
        }
        elsif (reftype($thing) eq 'HASH') {
            return join q(),
                map { $_ . q(:) . $thing->{$_} . q(.) }
                $self->_sort(keys %$thing);
        }
        else {
            die "Can't stringify: $thing";
        }
    }
    else {
        return "$thing.";
    }
}

=head2 $class->_sort(@items)

Returns a list containing the values of C<@items>, but sorted.  Sorts
numerically if C<@items> contains only numbers (according to
C<Scalar::Util::looks_like_number()>), otherwise sorts lexically.

=cut

sub _sort {
    my ($class, @items) = @_;
    if (grep { !looks_like_number($_) } @items) {
        return sort @items;
    }
    else {
        return sort { $a <=> $b } @items;
    }
}

=head2 $obj->digest($n)

Calculates and returns the I<n>th digest of the current keystring.  This is
done by bracketing C<< $obj->keystring >> with a "stringified" version of
C<$n>, then calculating the MD5 digest of the result.

The value returned is a 32-character string...

It is not necessary to use the MD5 checksum

There is nothing inherent in the Sortition algorithm.

a hexidecimal string containing the MD5 digest of
C<< $obj->keystring >> bracketed with a stringified version of C<$n>.

Returns the value of C<$n>, but C<pack()>ed into a little-endian, 2-byte short
int.

FIXME: find a coherent statement to make about the digest() method

=cut

# XXX

sub digest {
    my ($self, $n) = @_;
    my $pre = pack("n",$n);     # "n" => little-endian, 2-byte ("short int")
    return Digest::MD5::md5_hex($pre . $self->keystring . $pre);
}

=head2 $obj->seq

Returns a list of integers based on the dynamic keystring digest.  These
integers will be used will be used to choose the winners from the candidate
pool.

=cut

sub seq {
    my $self = shift;
    return map {
        my $hex = $self->digest($_);
        my $i = Math::BigInt->new("0x${hex}");
        if ($i->is_nan) {
            die("got invalid hex from digest($_): '$hex'");
        }
        $i;
    } 0 .. $self->n - 1;
}

=head2 $obj->result

Returns a data structure containing the contest results.  For sortition, the
structure is a list of candidates, with the first winner at list position 0,
etc.

=cut

sub result {
    my $self = shift;
    my $n = $self->n;
    my @seq = $self->seq;
    my @candidates = $self->candidates;
    my @result;
    while ($n) {
        my $j = shift @seq;
        $j->bmod(scalar @candidates);   # modifies $j
        # splice() out the chosen candidate into @result
        push @result, splice(@candidates, $j, 1);
        $n--;
    }
    return @result;
}

=head2 $obj->as_string

Returns the election results, formatted as a multiline string.

TODO: delegate formatting to an alternate class (via C<< $obj->formatter >>?)

=cut

sub as_string {
    my $self = shift;
    my $i = 0;
    return join q(), map { $i++; "$i. $_\n" } $self->result;
}

=pod

=head1 LIMITATIONS

=head1 SUBCLASSING

The core elements of the Sortition voting algorithm are the following:

1. choice of candidates
2. agreement on source of entropy
3. agreement on the digest function used to interpret the entropy

Package C<Algorithm::Voting::Sortition> makes specific choices in these matters:

    * the entropy is ... bracketed by source strings "\x00\x01", "\x00\x01", ...
    * the digest function is MD5

Other options include:

    * using a different digest function, e.g. SHA1, SHA256, etc.
    * using a different combining function to generate the chooser sequence

        - XOR the position with the 
        - stringify the position differently (e.g. use roman numerals, convert
          to a hex string, etc.)

As an example, here is a replacement digest method that uses a different digest
function (SHA1) and a different method to index the keystring (convert the
index to roman numerals, then 


alternate 

    package My::Sortition;

    use base 'Algorithm::Voting::Sortition';

    sub digest {
        my ($self, $n) = @_;
        use Digest::SHA1;
        use Roman 'Roman';      # uppercase
        my $prefix = Roman($n);
        my $hex = Digest::SHA1::sha1_hex($prefix ^ $self->keystring);
    }

=head2 Comment on Entropy

=head2 Comment on the use of the MD5 Digest Function


=cut

1;

