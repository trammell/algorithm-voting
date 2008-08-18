 

package Algorithm::Voting::Result;

sub new {
    my ($class) = @_;
    return bless { }, $class;
}

sub as_string {
    $self->formatter($self->summary);
}

1;

