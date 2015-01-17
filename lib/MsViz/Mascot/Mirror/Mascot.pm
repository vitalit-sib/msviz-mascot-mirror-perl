=head1 NAME

MsViz::Mascot::Mirror::Mascot - access mascot database definitions from ms-status.exe, runs etc.


=head1 SYNOPSIS


use MsViz::Mascot::Mirror::Mascot;


=cut
use strict;

use MsViz::Mascot::Mirror;
use LWP::Simple;
use XML::Twig;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(mascotSequenceDbList); 

=head1 FUNCTIONS

=head2 mascotSequenceDbList

get a list of existing sequence files on mascot nd a short description

=cut

sub mascotSequenceDbList{
    my %options = @_;

    my $url="$URL_MASCOT_SERVER/x-cgi/ms-status.exe?Show=MS_STATUSXML";

    my $xml=get($url) || die "cannot read $url:$!";

    my @dbs;
    my $twig=XML::Twig->new(   
	twig_handlers => 
	{ 'msst:Database'   => sub{
	    my ($twig, $edDb)=@_;
	    push @dbs, {
		name => $edDb->att('Name'),
		fileName => $edDb->first_child( 'msst:Filename')->text(),
		pathName => $edDb->first_child( 'msst:Pathname')->text()
	    }
	  }
	}
	);

    $twig->parsestring($xml) or die "cannot parse content of $url: $!";

    wantarray?@dbs:\@dbs;
}



1;
