# $Id$
use strict;

use Test::More tests => 3;

use Mac::iTunes;

my $Track_name = "The Wee Kirkcudbright Centipede";

my $controller = Mac::iTunes->new()->controller;
isa_ok( $controller, 'Mac::iTunes::AppleScript' );

$controller->play;
is( $controller->current_track_name, $Track_name, 
	'Fetch the current track name while playing' );

$controller->stop;
is( $controller->current_track_name, $Track_name, 
	'Fetch the current track name while stopped' );
