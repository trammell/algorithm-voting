#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Algorithm::Voting' );
}

diag( "Testing Algorithm::Voting $Algorithm::Voting::VERSION, Perl $], $^X" );
