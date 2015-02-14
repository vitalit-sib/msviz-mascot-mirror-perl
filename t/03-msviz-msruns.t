#!perl -T
use strict;
use warnings FATAL => 'all';
use Test::Mock::LWP::Dispatch;
use HTTP::Response;
use LWP::Simple;
use File::Slurp;
use Test::Most  tests => 2;

BEGIN {
    use_ok( 'MsViz::Mascot::Mirror::MsViz' ) || print "Bail out!\n";
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


$URL_MSVIZ_SERVER='http://msviz.mock';


addMockUrl('http://msviz.mock/msrun/list-runids', 'msviz-server/list-runids.js');

my @runs = msVizMsRunListRunIds();
is(scalar(@runs), 3, 'count msruns');

