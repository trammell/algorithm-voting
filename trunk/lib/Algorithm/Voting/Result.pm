# $Id$ 
# $URL$ 

package Algorithm::Voting::Result;

use strict;
use warnings;
use Params::Validate 'validate';

=pod

=head1 NAME

=head1 METHODS

=head2 Algorithm::Voting::Result->new( %args )

=cut

sub new {
    my $class = shift;
    my %valid = (
    	summary => 0,
	formatter => 0,
    );
    my %args = validate(@_, \%valid);
    return bless \%args, $class;
}

=head2 $obj->summary

=cut

sub summary {
    my $self = shift;
    return $self->{summary};
}

=head2 $obj->formatter

=cut

sub formatter {
    my $self = shift;
    return $self->{formatter};
}

=head2 $obj->as_string

=cut

sub as_string {
    my $self = shift;
    $self->formatter->($self->summary);
}

1;

