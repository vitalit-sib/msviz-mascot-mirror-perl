#!/usr/bin/env perl
use strict;
use Getopt::Long;
use MsViz::Mascot::Mirror;



my ($mascotServer, $msVizServer);
GetOptions("mascot=s" => \$mascotServer,
	   "msviz=s" => \$msVizServer,
	  ) or die "incorrect arguments";
