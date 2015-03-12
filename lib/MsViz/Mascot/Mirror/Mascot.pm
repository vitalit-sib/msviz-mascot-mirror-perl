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
use HTML::TableExtract;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw/mascotSequenceDbList mascotJobList mascotJob mascotJobMzId mascotJobMGF $URL_MASCOT_SERVER/; 

=head2 Global variables

=head3 $URL_MASCOT_SERVER

Url root to mascot server (such as http://mascot.your.domain/mascot). It can be default with environment variable $MSVIZ_MASCOT_SERVER

=cut

our $URL_MASCOT_SERVER = $ENV{MSVIZ_MASCOT_SERVER};

=head1 FUNCTIONS

=head2 mascotSequenceDbList

get a list of existing sequence files on mascot nd a short description

=over 

=item options: a map 

=over 

=item notIn=>Array: will return the database with names not included in the given list (typically, the one already loaded in MsViz)

=item in=>Array: will return the database with names  included in the given list

=back

=back

=cut

sub mascotSequenceDbList{
  my %options = @_;

  my $uri = 'x-cgi/ms-status.exe?Show=MS_STATUSXML';
  my $xml=_mascotGET($uri);

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

  $twig->parsestring($xml) or die "cannot parse content of mascot $uri: $!";

  if ($options{notIn}) {
    my %h;
    $h{$_}=1 foreach @{$options{notIn}};
    @dbs = grep {!$h{$_->{fileName}}} @dbs;
  }

  if ($options{in}) {
    my %h;
    $h{$_}=1 foreach @{$options{in}};
    @dbs = grep {$h{$_->{fileName}}} @dbs;
  }

  wantarray?@dbs:\@dbs;
}


sub _mascotGET{
  my $uri = shift;
  my $url = "$URL_MASCOT_SERVER/$uri";
  get($url) || die "cannot GET $url:$!";
}

=head2 mascotJobList

Returns a list of jobs (the last 5000 at most), parsing ms-review.exe (and picking up the second table).
An array is returns, with each element a hash map correponding to the column names.

=cut

sub mascotJobList{

  my $url="$URL_MASCOT_SERVER/x-cgi/ms-review.exe?start=-1&howMany=5000&pathToData=&showGetSeq=on&column=0&s0=1&s1=1&s2=1&s3=1&s4=1&s5=1&s7=1&s8=1&s9=1&s10=1&s11=1&s12=1&s14=1";
  my $content = get($url) || die "could not read content from $url";
  
  my $te =  HTML::TableExtract->new(keep_html =>1);
  $te->parse($content);
  my @rows = ($te->tables)[1]->rows;

  my @headers = map {s/\W+//g; s/^b//i; s/b$//i; $_} @{$rows[0]};

  map {my $row = $_;
       my %ret;
       for (0..$#headers){
	 $ret{$headers[$_]}=$row->[$_];
       }
       $ret{Job}=~/\/(\d{8})\/(\w\d+)\.dat/ or die "cannot parse jobid and date tag out of $ret{Job}";
       $ret{jobId}=$2;
       $ret{jobDateTag}=$1;
       $ret{Job}=~/file=(.+?)"/ or die "cannot parse file=... out of $ret{Job}";
       $ret{jobFile}="$1";

       \%ret;
     } @rows[4..$#rows];
}

=head2 mascotJob(jobId)

Returns one job, given by a job id tag (e.g. 'F123556'), either as a form of a ash or a hash pointer.

=cut

sub mascotJob{
  my $jid=shift;
 
  my @jobs = mascotJobList();
  my @j = grep {$_->{jobId} eq $jid} @jobs;
  return $j[0];
}



=head2 mascotJobMzId(jobId)

Returns the mzId contents for a given jobId

=cut 

sub mascotJobMzId {
  my $jid = shift;
  my $job = mascotJob($jid) || die "cannot retrieve job definition for $jid";
  
  my $uri="cgi/export_dat_2.pl?file=$job->{jobFile};_ignoreionsscorebelow=14;_minpeplen=5;_noerrortolerant=0;_onlyerrortolerant=0;_prefertaxonomy=0;_requireboldred=0;_server_mudpit_switch=0.000000001;_show_decoy_report=0;_showallfromerrortolerant=0;_showsubsets=1;_sigthreshold=0.05;_target_fdr=;do_export=1;export_format=mzIdentML;group_family=1;pep_exp_mz=1;pep_isbold=1;pep_isunique=1;pep_query=1;pep_rank=1;peptide_master=1;prot_acc=1;prot_desc=1;prot_hit_num=1;report=0;sessionID=all_secdisabledsession;show_pep_dupes=1;use_homology=1;generate_file=1";
  _mascotGET($uri);
}

=head2 mascotJobMGF(jobId)

Returns the MGF contents for a given jobId

=cut 

sub mascotJobMGF {
  my $jid = shift;
  my $job = mascotJob($jid) || die "cannot retrieve job definition for $jid";
  
  my $uri="cgi/export_dat_2.pl?group_family=1&_showsubsets=1&file=$job->{jobFile}&do_export=1&export_format=MGF&generate_file=1";
  _mascotGET($uri);
}

1;
