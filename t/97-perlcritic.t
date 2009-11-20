use strict;
use warnings;
use File::Spec;
use Test::More;
use English qw(-no_match_vars);

eval "use Test::Perl::Critic (-severity => 1);";

if ($EVAL_ERROR) {
    my $msg = 'Test::Perl::Critic required to criticise code';
    plan( skip_all => $msg );
}

my $rcfile = File::Spec->catfile( 't', 'perlcriticrc' );
Test::Perl::Critic->import( -profile => $rcfile );
all_critic_ok();

