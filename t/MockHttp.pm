use strict;
use Test::Mock::LWP::Dispatch;
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
