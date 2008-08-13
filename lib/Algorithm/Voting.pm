package Algorithm::Voting;

use warnings;
use strict;

our $VERSION = '0.01';

1;

=pod

=head1 NAME

Algorithm::Voting - implementations of various voting algorithms

=head1 SYNOPSIS

    use Algorithm::Voting::Ballot;
    use Algorithm::Voting::Borda;
    my $box = Algorithm::Voting->new();

=head1 AUTHOR

johntrammell@gmail.com, C<< <johntrammell at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-algorithm-voting at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Algorithm-Voting>.  I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Algorithm::Voting

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Algorithm-Voting>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Algorithm-Voting>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Algorithm-Voting>

=item * Search CPAN

L<http://search.cpan.org/dist/Algorithm-Voting>

=back

=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 johntrammell@gmail.com, all rights reserved.

This software is intended for educational and entertainment purposes only.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

