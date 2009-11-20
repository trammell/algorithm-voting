# $Id: 01-key.t 42 2008-08-28 19:20:00Z johntrammell $
# $URL: https://algorithm-voting.googlecode.com/svn/trunk/t/sortition/01-key.t $

use strict;
use warnings;
use Test::More 'no_plan';
use Test::Exception;
use Data::Dumper;
use Algorithm::Voting::InstantRunoff;

my $avi = 'Algorithm::Voting::InstantRunoff';

{
    my %hash;
    my @key = ('a' .. 'c');

    $avi->increment_key(\%hash, ('a'));
    $avi->increment_key(\%hash, ('a' .. 'b'));
    $avi->increment_key(\%hash, ('a' .. 'c'));
#   diag(Dumper(\%hash));
}

