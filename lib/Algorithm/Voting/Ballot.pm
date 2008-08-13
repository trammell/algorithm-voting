# $Id$
# $URL$

package Algorithm::Voting::Ballot;

use base 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw/ candidate /);

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    if (@_ == 1) {
        $self->candidate($_[0]);
    }
    return $self;
}


1;

