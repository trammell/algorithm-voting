
package Algorithm::Voting::Sortition;

use strict;
use warnings;
use Scalar::Util 'reftype';
use Digest::MD5;
use Math::BigInt;
use Params::Validate 'validate';
use base 'Class::Accessor::Fast';

=pod

=head1 NAME

Algorithm::Voting::Sortition - implements RFC 3797, "Publicly Verifiable
Nominations Committee (NomCom) Random Selection"

=head1 SYNOPSIS

Assuming we want to choose two of our favorite Flintstones pals:

    use Algorithm::Voting::Sortition;
    my @candidates = qw/ fred wilma barney betty pebbles bamm-bamm /;
    my @keysource = (
        [32,40,43,49,53,21],  # 8/9/08 powerball numbers
        "W 4-1",              # final score of 8/8/08 Twins game
    );
    my $race = Algorithm::Voting::Sortition->new(
        candidates => \@candidates,
        source     => \@keysource,
        n          => 2,
    );
    printf "Key string is: '%s'\n", $race->keystring;
    print $race->as_string;

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

Returns the number of candidates to choose from the master list.

=cut

sub n {
    my $self = shift;
    if ($self->{n} < 1) {
        $self->{n} = scalar($self->candidates);
    }
    return $self->{n};
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

=cut

sub stringify {
    my ($self, $thing) = @_;
    if (reftype($thing) && reftype($thing) eq 'ARRAY') {
        my @x = sort { $a <=> $b } @$thing;
        return join q(), map "$_.", @x;
    }
    else {
        return "$thing.";
    }
}

=head2 $obj->digest($n)

Calculates and returns the I<n>th digest of the current keystring.  This is
done by bracketing C<< $obj->keystring >> with a stringified version of C<$n>,
then calculating the MD5 digest of the result.

It is not necessary to use the MD5 checksum

There is nothing inherent in the Sortition algorithm.

a hexidecimal string containing the MD5 digest of
C<< $obj->keystring >> bracketed with a stringified version of C<$n>.

Returns the value of C<$n>, but C<pack()>ed into a little-endian, 2-byte short
int.

FIXME: find a coherent statement to make about the digest() method

=cut

sub digest {
    my ($self, $n) = @_;
    my $pre = pack("n",$n);     # "n" => little-endian, 2-byte ("short int")
    my $hex = Digest::MD5::md5_hex($pre . $self->keystring . $pre);
}

=head2 $obj->seq

Returns a list of integers based on the dynamic keystring digest.  These
integers will be used will be used to choose the winners from the candidate
pool.

=cut

sub seq {
    my $self = shift;
    map {
        my $hex = $self->digest($_);
        Math::BigInt->new("0x${hex}");
    } 0 .. $self->n - 1;
}

=head2 $obj->result

Returns the data structure containing the contest results.

=cut

sub result {
    my $self = shift;
    unless (exists $self->{result}) {
        $self->{result} = [ $self->make_result ];
    }
    return $self->{result};
}

=head2 $obj->make_result

=cut

sub make_result {
    my $self = shift;
    my $n = $self->n;
    my @seq = $self->seq;
    my @candidates = $self->candidates;
    my @result;
    while ($n) {
        my $j = shift @seq;
        my $i = $j->bmod($n);
        # splice() out the chosen candidate into @result
        push @result, splice(@candidates, $i, 1);
    }
    return @result;
}

=head2 $obj->as_string

Delegates formatting to class C<< $obj->formatter >>.

=cut

sub as_string {
    my $self = shift;
    my $fmt_class = $self->formatter; 
    $fmt_class->as_string($self->result);
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

