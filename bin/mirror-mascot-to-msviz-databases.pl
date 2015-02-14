#!/usr/bin/env perl

=head1 mirror-mascot-to-msviz-databases.pl

Mirror sequence sdatasources (fasta) from a mascot server to a MsViz server

=head1 SYNOPSIS

    mirror-mascot-to-msviz-databases.pl  --mascot=http://mascot.domain.ch/mascot --msviz=http://mzviz.domain.ch --import-only=list

    mirror-mascot-to-msviz-databases.pl  --mascot=http://mascot.domain.ch/mascot --msviz=http://mzviz.domain.ch --import-only=SwissProt_2014_08.fasta


=head1 ARGUMENTS

=over 1

=item --mascot=url the http mascot address (must be passwordless)

=item --msviz=url the MsViz http backend

=back

=head1 OPTIONS

=over 1

=item --list: print the available sequence databases on mascot side and if they eventually have been mirrored on msViz

=item --mascot-host=hostname: if the script is not executed directly on the mascot server, it may not have access directly to the fasta file to upload to MsViz. Setting a hst will allowforce to make a local copy first via scp.

=back 

=cut

use strict;
use Getopt::Long;
use Pod::Usage;
use MsViz::Mascot::Mirror;
use MsViz::Mascot::Mirror::Mascot;
use MsViz::Mascot::Mirror::MsViz;

my ($listDbs, $importOnly, $remoteMascot, $help);
GetOptions("mascot=s" => \$URL_MASCOT_SERVER,
	   "msviz=s" => \$URL_MSVIZ_SERVER,
	   "list" => \$listDbs,
	   "import-only=s" => \$importOnly,
	   "mascot-host=s" => \$remoteMascot,
	   "help" => \$help  
	  ) or pod2usage(-exitval => 1);
pod2usage(-exitval => 0) if($help);

warn "mirror sequences databases from $URL_MASCOT_SERVER to $URL_MSVIZ_SERVER\n";

if($listDbs){
    my @msVizDbs=msVizSequenceDbList();
    my %h;
    $h{$_}=1 foreach @msVizDbs;
    use Data::Dumper;
    warn Dumper(\%h);
    foreach my $db(mascotSequenceDbList()){
      print "".($h{$db->{fileName}}?'ok         ':'not mirrored')."\t$db->{fileName}\n";
    }
    exit(0);
}

my %opts;
if($importOnly){
  my @tmp = split /,/, $importOnly;
  $opts{in}=\@tmp;
}else{
  my @msVizDbs=msVizSequenceDbList();
  warn "".scalar(@msVizDbs)." databases already imported\n";
  $opts{noIn}=\@msVizDbs;
}

my @mascotDbs=mascotSequenceDbList(%opts);

foreach my $db(@mascotDbs){
  warn "importing $db->{fileName}\n";
  msVizImportSequences($db, remote => $remoteMascot);
}
