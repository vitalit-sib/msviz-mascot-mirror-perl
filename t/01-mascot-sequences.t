#!perl -T
use strict;
use warnings FATAL => 'all';
use Test::Mock::LWP::Dispatch;
use HTTP::Response;
use LWP::Simple;
use File::Slurp;
use Test::Most  tests => 4;

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

addMockUrl('http://example.com', 'hello.txt');
my $ct = get('http://example.com');
is ($ct, "paf le chien\n", 'checking out httpd mock');

addMockUrl('http://mascot.mock/mascot/x-cgi/ms-status.exe?Show=MS_STATUSXML', 'mascot-server/ms-status.xml');

my @databases = mascotSequenceDbList();
is(scalar(@databases), 8, 'database array length');

is_deeply($databases[7], {'pathName' => '/local/mascot_server_2-4_data/sequence/UniProtKB/current/uniprot_2013_12.fasta',
			  'fileName' => 'uniprot_2013_12.fasta',
			  'name' => 'UniProtKB'}, 'db details');
