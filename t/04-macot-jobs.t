#!perl -T
use strict;
use warnings FATAL => 'all';
use Test::Mock::LWP::Dispatch;
use HTTP::Response;
use LWP::Simple;
use File::Slurp;
use Test::Most  tests => 10;

BEGIN {
    use_ok( 'MsViz::Mascot::Mirror::Mascot' ) || print "Bail out!\n";
}

sub addMockUrl{
    my ($url, $file)=@_;
    $mock_ua->map($url, 
		  sub {
		      my $r = HTTP::Response->new(200);
		      my $f = "t/resources/httpd/$file";
		      my $content = read_file($f); 
		      $r->content($content);
		      $r;
		  });
}

$URL_MASCOT_SERVER='http://mascot.mock/mascot';


my $url ='http://mascot.mock/mascot/x-cgi/ms-review.exe?start=-1&howMany=5000&pathToData=&showGetSeq=on&column=0&s0=1&s1=1&s2=1&s3=1&s4=1&s5=1&s7=1&s8=1&s9=1&s10=1&s11=1&s12=1&s14=1';
addMockUrl($url, 'mascot-server/ms-review.exe');

my $ct = get($url);
ok(defined $ct, 'check read content');

my @jobs = mascotJobList();
is(scalar(@jobs), 4, 'count jobs');

my %job = %{$jobs[1]};
is($job{jobId}, 'F002350', 'jobId');
is($job{jobDateTag}, '20120115', 'jobDateTag');
is($job{jobFile}, '../data/20120115/F002350.dat', 'jobFile');
is($job{Title}, 'other title', 'Title');

%job = %{mascotJob('F002350')};
is($job{jobId}, 'F002350', 'mascotJob - jobId');
is($job{jobDateTag}, '20120115', 'mascotJob- jobDateTag');
is($job{Title}, 'other title', 'mascotJob - Title');
