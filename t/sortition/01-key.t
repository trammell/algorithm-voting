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

# verify example in L<http://tools.ietf.org/html/rfc3797#section-6>
{
    my @source = (
        "9319",
        [ qw/ 2 5 12 8 10 / ],
        [ qw/ 9 18 26 34 41 45 /],
    );
    my $key = q(9319./2.5.8.10.12./9.18.26.34.41.45./);
    is ($avs->make_keystring(@source), $key);

    my $digest = sub {
        my $p = $avs->prefix($_[0]);
        return uc(md5_hex($p . $key . $p));
    };

    # digests from URL http://tools.ietf.org/html/rfc3797#section-6; the first
    # is the digest of the keystring bracketed by the string "\x00\x00", the
    # next "\x00\x01", and so on.

    my @rfc_digests = split(/\n/,<<__sums__);
990DD0A5692A029A98B5E01AA28F3459
3691E55CB63FCC37914430B2F70B5EC6
FE814EDF564C190AC1D25753979990FA
1863CCACEB568C31D7DDBDF1D4E91387
F4AB33DF4889F0AF29C513905BE1D758
13EAEB529F61ACFB9A29D0BA3A60DE4A
992DB77C382CA2BDB9727001F3CDCCD9
63AB4258ECA922976811C7F55C383CE7
DFBC5AC97CED01B3A6E348E3CC63F40D
31CB111C4A4EBE9287CEAE16FE51B909
07FA46C122F164C215BBC72793B189A3
AC52F8D75CCBE2E61AFEB3387637D501
53306F73E14FC0B2FBF434218D25948E
B5D1403501A81F9A47318BE7893B347C
85B10B356AA06663EF1B1B407765100A
3269E6CE559ABD57E2BA6AAB495EB9BD
__sums__

    for my $i (0 .. $#rfc_digests) {
        is($md5->($i),$rfc_digests[$i]);
    }

}

