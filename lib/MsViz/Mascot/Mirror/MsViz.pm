package MsViz::Mascot::Mirror::MsViz;

=head1 NAME

MsViz::Mascot::Mirror::MsViz - access and post sequences, runs etc from/to MsViz server


=head1 SYNOPSIS

use MsViz::Mascot::Mirror::MsViz;

=cut
use strict;

use LWP::Simple;
use LWP::UserAgent;
use HTTP::Request::Common  qw/POST/;
use JSON;
use File::Temp qw/tempfile/;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw/msVizSequenceDbList msVizImportSequences msVizMsRunListRunIds $URL_MSVIZ_SERVER/; 


=head2 EXPORT

=head3 $URL_MSVIZ_SERVER

The url root to msViz server backend (such as http://localhost:9000 in dev mode)

=cut

our $URL_MSVIZ_SERVER;

=head1 FUNCTIONS

=head2 msVizSequenceDbList

get a list of existing sequence files on msViz and a short description

=cut

sub msVizSequenceDbList{
  my %options = @_;

  my $url="$URL_MSVIZ_SERVER/sequences/list-sources";

  my $json=get($url) || die "cannot read $url:$!";

  my @dbs = @{from_json ($json)};
  wantarray?@dbs:\@dbs;
}

=head2 msVizMsRunListRunIds

get a list of existing msRunId

=cut

sub msVizMsRunListRunIds{
  my %options = @_;

  my $url="$URL_MSVIZ_SERVER/msrun/list-runids";

  my $json=get($url) || die "cannot read $url:$!";

  my @runIds = @{from_json ($json)};
  wantarray?@runIds:\@runIds;
}

=head2 msVizImportSequences(db, opts)

Imports a sequence fasta vit a http POST query

db must contain

=over

=item fileName

=item pathName

=back

opts can contain 

=over 

=item remote => host: if resent, the filename will be copied by ssh from the host locally before being forwarded, then deleted (the local copy, don't panic).
Can be of the form "hostname" or "user@hostname"

=cut

sub msVizImportSequences{
  my $db=shift;
  my %opts = @_;


  my $url="$URL_MSVIZ_SERVER/sequences/".$db->{fileName}."/fasta";

  my $localFile = $db->{pathName};
  if ($opts{remote}) {
    my (undef, $tmpFile) = tempfile();
    my $cmd = "scp $opts{remote}:$db->{pathName} $tmpFile";
    print "temp local copy: $cmd\n";
    system ($cmd) and die "cannot execut scp command: $!";
    print "uploading to msViz server\n";
    $localFile = $tmpFile;
  } else {
    unless(-f $localFile){
      warn "cannot import $localFile: $localFile does not exists or is not readable";
      return;
    }
  }

  my $content;
  {
    local $/;
    open my $FD, '<', $localFile or die "cannot open file for reading: $!";
    $content=<$FD>;
    if ($opts{remote}) {
      unlink $localFile;
    }
  }
  
  my $ua = LWP::UserAgent->new();
  my $req =  POST $url,
    Content_Type => 'plain/text',
    Content      =>  $content ;
  
  my $response = $ua->request($req);


  
  die "Error: ", $response->status_line . "\n". $response->content unless $response->is_success;
  from_json($response->content);
}
1;
