#!perl -T
use strict;
use Test::More;

BEGIN {
  plan tests => 1;
    use_ok( 'MsViz::Mascot::Mirror' ) || print "Bail out!\n";
}

diag( "Testing MsViz::Mascot::Mirror $MsViz::Mascot::Mirror::VERSION, Perl $], $^X" );
