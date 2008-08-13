# $Id$
# $URL$

use Test::More 'no_plan';

use_ok('Algorithm::Voting::Sortition');

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

my @candidates = qw/
    John Mary Bashful Dopey Sleepy
    Grouchy Doc Sneazy Handsome Cassandra
    Pollyanna Pendragon Pandora Faith Hope
    Charity Lee Longsuffering Chastity Smith
    Pride Sloth Envy Anger Kasczynski
/;

my $key = q(9319./2.5.8.10.12./9.18.26.34.41.45./);

my $box = Algorithm::Voting::Sortition(candidates => \@c, key => $key);

print $box->results->as_string;

