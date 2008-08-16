# $Id$
# $URL$

package Algorithm::Voting::Ballot;

use base 'Class::Accessor::Fast';

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
    my $self = bless {}, $class;
    if (@_ == 1) {
        $self->candidate($_[0]);
    }
    return $self;
}

1;

