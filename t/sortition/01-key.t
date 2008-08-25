# $Id$
# $URL$

use strict;
use warnings;
use Test::More 'no_plan';
use Digest::MD5 'md5_hex';

my $avs = 'Algorithm::Voting::Sortition';

use_ok($avs);

# verify that class method "make_keystring" works correctly
{
    my $x = [1,2,3];
    my $y = [1,3,2];
    my @tests = (
        [ [ $x ] => q(1.2.3./) ],
    );
    foreach my $i (0 .. $#tests) {
        my @in = @{ $tests[$i][0] };
        my $out = $tests[$i][1];
        is($avs->make_keystring(@in),$out);
    }
}

