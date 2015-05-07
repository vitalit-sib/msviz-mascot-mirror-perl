package MsViz::Mascot::Mirror;
use strict;

=head1 NAME

MsViz::Mascot::Mirror - Mirroring data between a mascot and msViz servers

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.02';


=head1 SYNOPSIS

   export MSVIZ_MASCOT_SERVER=http://mascot.domain.ch/mascot
   export MSVIZ_MSVIZ_SERVER=http://mzviz.domain.ch/backend

   mirror-mascot-to-msviz-databases.pl  --list

   mirror-mascot-to-msviz-databases.pl --import-only=SwissProt_2014_08.fasta

   mirror-mascot-to-msviz-searches.pl --jobs=F000456,F000789

=head1 



=head1 AUTHOR

Alexandre Masselot, C<< <alexandre.masselot at isb-sib.com> >>

=head1 BUGS

Please report any bugs or feature requests to https://github.com/vitalit-sib/msviz-backend/issues


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MsViz::Mascot::Mirror


Source code can be found at https://github.com/vitalit-sib/msviz-mascot-mirror-perl

=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 SIB Swiss Institute of Bioinformatics

=cut

use MsViz::Mascot::Mirror::Mascot;
use MsViz::Mascot::Mirror::MsViz;

1; # End of MsViz::Mascot::Mirror
