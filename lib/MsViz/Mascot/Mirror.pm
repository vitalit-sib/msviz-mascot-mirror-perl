package MsViz::Mascot::Mirror;
use strict;

=head1 NAME

MsViz::Mascot::Mirror - The great new MsViz::Mascot::Mirror!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS


=head1 



=head1 AUTHOR

Alexandre Masselot, C<< <alexandre.masselot at isb-sib.com> >>

=head1 BUGS

Please report any bugs or feature requests to 

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MsViz::Mascot::Mirror




=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 SIB Swiss Institute of Bioinformatics

=cut

require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT= qw/$URL_MASCOT_SERVER $URL_MSVIZ_SERVER/;


=head1 EXPORT

=head2 Global variables

=head3 $URL_MASCOT_SERVER

Url root to mascot server (such as http://mascot.vital-it.ch/mascot)

=cut


our $URL_MASCOT_SERVER;

=head3 $URL_MSVIZ_BACKEND

The url root to msViz server backend (such as http://localhost:9000 in dev mode)

=cut

our $URL_MSVIZ_BACKEND;

1; # End of MsViz::Mascot::Mirror
