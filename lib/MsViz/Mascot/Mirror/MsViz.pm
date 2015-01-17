=head1 NAME

MsViz::Mascot::Mirror::MsViz - access and post sequences, runs etc from/to MsViz server


=head1 SYNOPSIS

use MsViz::Mascot::Mirror::MsViz;

=cut
use strict;

use MsViz::Mascot::Mirror;
use LWP::Simple;
use JSON::Parse 'parse_json';

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(msVizSequenceDbList); 

=head1 FUNCTIONS

=head2 msVizSequenceDbList

get a list of existing sequence files on msViz and a short description

=cut

sub msVizSequenceDbList{
    my %options = @_;

    my $url="$URL_MSVIZ_SERVER/sequences/list-sources";

    my $json=get($url) || die "cannot read $url:$!";

    my @dbs = @{parse_json ($json)};
    wantarray?@dbs:\@dbs;
}

1;
