use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
				 module_name         => 'MsViz::Mascot::Mirror',
				 license             => 'Artistic_2_0',
				 dist_author         => q{Alexandre Masselot <alexandre.masselot@isb-sib.com>},
				 dist_version_from   => 'lib/MsViz/Mascot/Mirror.pm',
				 release_status      => 'stable',
				 configure_requires => {
							'Module::Build' => 0,
						       },
				 build_requires => {
						    'Test::Most' => 0,
						    'Test::Mock::LWP::Dispatch' => 0,
						    'File::Slurp' => 0,
						    'TAP::Formatter::JUnit' => 0
						   },
				 requires => {
					      'XML::Twig' => 0,
					      'LWP::Simple' => 0,
					      'HTTP::Request::Common' => 0,
					      'JSON' => 0,
					      'Pod::Usage' => 0,
					      'HTML::TableExtract'=>0
					     },
				 add_to_cleanup     => [ 'MsViz-Mascot-Mirror-*' ],
				 create_makefile_pl => 'traditional',
				);

$builder->create_build_script();
