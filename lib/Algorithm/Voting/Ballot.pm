# $Id$
# $URL$

package Algorithm::Voting::Ballot;
use base 'Class::Accessor::Fast';
use Params::Validate 'validate';

__PACKAGE__->mk_accessors(qw/ candidate /);

=pod

=head1 NAME

Algorithm::Voting::Ballot - represents a ballot to cast in a race

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 Algorithm::Voting::Ballot->new()

    # vote for Pedro
    my $ballot = Algorithm::Voting::Ballot->new('Pedro')

=cut

sub new {
    my $class = shift;
    if (@_ == 1) {
        return $class->new(candidate => $_[0]);
    }
    my %valid = (
        candidate => 0,
    );
    my %args = validate(@_, \%valid);
    return bless \%args, $class;
}

1;

