
use Test::More 'no_plan';
use Test::Exception;

use_ok('Algorithm::Voting::Plurality');
use_ok('Algorithm::Voting::Ballot');

my $ballot = sub {
    return Algorithm::Voting::Ballot->new($_[0]);
};

my $box = Algorithm::Voting::Plurality->new( candidates => [qw/ frank mary judy /] );
ok($box);

ok($box->add($ballot->('frank')));
is($box->count,1);

ok($box->add($ballot->('mary')));
is($box->count,2);

ok($box->add($ballot->('judy')));
is($box->count,3);

ok($box->add($ballot->('mary')));
is($box->count,4);

ok($box->add($ballot->('frank')));
is($box->count,5);

# try to insert an invalid ballot
dies_ok { $box->add($ballot->('steve')) } 'dies on invalid candidate';
is($box->count,5);

is_deeply( $box->result)


