
use Test::More 'no_plan';
use Data::Dumper;

use_ok('Algorithm::Voting::Plurality');
use_ok('Algorithm::Voting::Ballot');

my $ballot = sub {
    return Algorithm::Voting::Ballot->new($_[0]);
};

my $box = Algorithm::Voting::Plurality->new();
ok($box);

ok($box->add($ballot->('frank')));
is($box->count,1);

ok($box->add($ballot->('mary')));
is($box->count,2);

ok($box->add($ballot->('frank')));
is($box->count,3);

ok($box->add($ballot->('mary')));
is($box->count,4);

ok($box->add($ballot->('frank')));
is($box->count,5);

is_deeply($box->tally, { frank => 3, mary => 2 }) or diag(Dumper($box));

diag(Dumper($box->result));
diag($box->as_string);


