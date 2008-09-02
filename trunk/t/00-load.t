#!perl -T

use Test::More tests => 5;

BEGIN {
    use_ok('Algorithm::Voting');
    use_ok('Algorithm::Voting::Ballot');
    use_ok('Algorithm::Voting::InstantRunoff');
    use_ok('Algorithm::Voting::Plurality');
    use_ok('Algorithm::Voting::Sortition');
}

diag("Testing Algorithm::Voting $Algorithm::Voting::VERSION, Perl $], $^X");

