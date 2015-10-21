#!/usr/bin/env perl

=head1 mirror-mascot-to-msviz-searches.pl

Mirror search results from a mascot server to a MsViz server

=head1 SYNOPSIS

    mirror-mascot-to-msviz-searches.pl  --mascot=http://mascot.domain.ch/mascot --msviz=http://mzviz.domain.ch --list

    #if the job number does not match F\d{6}, but is a number, it will be converted to "F%6.6d"
    mirror-mascot-to-msviz-searches.pl  --mascot=http://mascot.domain.ch/mascot --msviz=http://mzviz.domain.ch/backend --jobs=F123456,789

   #or via environment variables
   export MSVIZ_MASCOT_SERVER=http://mascot.domain.ch/mascot
   export MSVIZ_MSVIZ_SERVER=http://mzviz.domain.ch/backend
   mirror-mascot-to-msviz-searches.pl --jobs=F000456,F000789


=head1 ARGUMENTS

=over 1

=item --mascot=url the http mascot address (must be passwordless)

=item --msviz=url the MsViz http backend

=back

=head1 OPTIONS

=over 1

=item --list: print the available search jobs

=item --jobs=id1[,id2,...] the list of jobs to import (--list and --jobs=... are exclusive)

=back 

=cut

use strict;
use Getopt::Long;
use Pod::Usage;
use MsViz::Mascot::Mirror;
use MsViz::Mascot::Mirror::Mascot;
use MsViz::Mascot::Mirror::MsViz;

my ($list, $jobs, $help);
GetOptions("mascot=s" => \$URL_MASCOT_SERVER,
	   "msviz=s" => \$URL_MSVIZ_SERVER,
	   "list" => \$list,
	   "jobs=s" => \$jobs,
	   "help" => \$help  
	  ) or pod2usage(-exitval => 1);
pod2usage(-exitval => 0) if($help);

warn "mirror search results from $URL_MASCOT_SERVER to $URL_MSVIZ_SERVER\n";

if($list){
    my @jobs=mascotJobList();
    print "job\tdate\tdbase\tuser\ttitle\n";
    foreach my $j (@jobs){
      print "$j->{jobId}\t$j->{starttime}\t$j->{dbase}\t$j->{UserName}\t$j->{Title}\n";
    }
    exit(0);
}

foreach my $jid (split /,/, $jobs){
  $jid = sprintf("F%6.6d", $jid) unless $jid =~ /F\d{6}/;
  
  my $job = mascotJob($jid);
  my $searchId="$job->{jobId}";
  
  print "retieving mzIdMGF for $job->{jobId}\n";
  my $mgf = mascotJobMGF($jid);
  print "retieving mzId for $job->{jobId}\n";
  my $mzId = mascotJobMzId($jid);

  open my $FD, '>', '/tmp/a.mgf';
  print $FD $mgf;
  close $FD;
  
  print "uploading MGF $searchId\n";
  my $resp = msVizUploadMGF($searchId, $mgf);
  print "$resp\n";
  print "uploading psms $searchId\n";
  my $resp = msVizUploadMzId($searchId, $mzId);
  print "$resp\n";
}


