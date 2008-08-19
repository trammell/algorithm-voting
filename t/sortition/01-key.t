# $Id$
# $URL$

use strict;
use warnings;
use Test::More 'no_plan';

my $avs = 'Algorithm::Voting::Sortition';

use_ok($avs);

# verify that "make_key" works correctly
{
    my $x = [1,2,3];
    my $y = [1,3,2];
    my @tests = (
        [ [ $x ] => q(1.2.3./) ],
    );
    foreach my $i (0 .. $#tests) {
        my @in = @{ $tests[$i][0] };
        my $out = $tests[$i][1];
        is($avs->make_key(@in),$out);
    }
}

# verify example in L<http://tools.ietf.org/html/rfc3797#section-6>
{
    my @source = (
        "9319",
        [ qw/ 2 5 12 8 10 / ],
        [ qw/ 9 18 26 34 41 45 /],
    );
    my $key = q(9319./2.5.8.10.12./9.18.26.34.41.45./);
    is ($avs->make_key(@source), $key);
}

{
    is($avs->make_prefix(1),"\x00\x01");
    is($avs->make_prefix(2),"\x00\x02");
    is($avs->make_prefix(8),"\x00\x08");
    is($avs->make_prefix(31),"\x00\x1f");
    is($avs->make_prefix(32),"\x00\x20");
    is($avs->make_prefix(256),"\x01\x00");
    is($avs->make_prefix(257),"\x01\x01");
    is($avs->make_prefix(0xffff),"\xff\xff");
}

