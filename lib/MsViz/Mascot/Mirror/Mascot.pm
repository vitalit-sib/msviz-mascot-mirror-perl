package MsViz::Mascot::Mirror::Mascot;

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
our @EXPORT = qw/mascotSequenceDbList $URL_MASCOT_SERVER/; 

=head2 Global variables

=head3 $URL_MASCOT_SERVER

Url root to mascot server (such as http://mascot.vital-it.ch/mascot)

=cut

our $URL_MASCOT_SERVER;

=head1 FUNCTIONS

=head2 mascotSequenceDbList

get a list of existing sequence files on mascot nd a short description

=over 

=item options: a map 

=over 

=item notIn=>Array: will return the database with names not included in the given list (typically, the one laready loaded in MsViz)

=back

=back

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

    if($options{notIn}){
      my %h;
      $h{$_}=1 foreach @{$options{notIn}};
      @dbs = grep {!$h{$_->{fileName}}} @dbs;
    }

    wantarray?@dbs:\@dbs;
}



1;
