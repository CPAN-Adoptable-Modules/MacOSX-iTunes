# $Id$

use Test::More tests => 7;

my @classes = ( "Mac::iTunes", map { "Mac::iTunes::$_" } qw( AppleScript FileFormat
	Playlist Item Library::Parse Library::Write ) );
	
foreach my $class ( @classes )
	{
	use_ok( $class );
	}
