# $Id$
# $URL$

use strict;
use warnings;
use Test::More 'no_plan';

use_ok('Algorithm::Voting::Sortition');

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
        is(Algorithm::Voting::Sortition->make_key(@in),$out);
    }
}

#   1. John         11. Pollyanna       21. Pride
#   2. Mary         12. Pendragon       22. Sloth
#   3. Bashful      13. Pandora         23. Envy
#   4. Dopey        14. Faith           24. Anger
#   5. Sleepy       15. Hope            25. Kasczynski
#   6. Grouchy      16. Charity
#   7. Doc          17. Lee
#   8. Sneazy       18. Longsuffering
#   9. Handsome     19. Chastity
#  10. Cassandra    20. Smith

my @c = qw/
    John Mary Bashful Dopey Sleepy
    Grouchy Doc Sneazy Handsome Cassandra
    Pollyanna Pendragon Pandora Faith Hope
    Charity Lee Longsuffering Chastity Smith
    Pride Sloth Envy Anger Kasczynski
/;

# http://tools.ietf.org/html/rfc3797#section-6
my @source = (
    "9319",
    [ qw/ 2 5 12 8 10 / ],
    [ qw/ 9 18 26 34 41 45 /],
);

my $key = q(9319./2.5.8.10.12./9.18.26.34.41.45./);

is(Algorithm::Voting::Sortition->make_key(@source), $key);

# return 5 winners, using key $key
my $box = Algorithm::Voting::Sortition->new(candidates => \@c, key => $key, n => 5);

warn $box->result->as_string;

