# $Id$
use strict;

use vars qw(@files @scripts);

BEGIN {
	use File::Find::Rule;
	@files = File::Find::Rule->file()->name( '*.pm' )->in( 'blib/lib' );
	@scripts = qw(tk/tk-itunes.pl cgi/iTunes.cgi);
	}

use Test::Pod tests => scalar @files + scalar @scripts;

foreach my $file ( @files, @scripts )
	{
	pod_ok($file);
	}
