# $Id$
use strict;

use lib  qw(./t/lib ./lib);

use Test::More tests => 4;
use Mac::iTunes;

require "test_data.pl";

my $controller = Mac::iTunes->new()->controller;
isa_ok( $controller, 'Mac::iTunes::AppleScript' );

$controller->set_playlist( $iTunesTest::Test_playlist );
my $name = $controller->get_track_at_position( 1 );

is( $name, $iTunesTest::Track_name, "Track name at position 1" );

$controller->play_track(1, $iTunesTest::Test_playlist);
is( $controller->current_track_name, $iTunesTest::Track_name, 
	'Fetch the current track name while playing' );

$controller->stop;
is( $controller->current_track_name, $iTunesTest::Track_name, 
	'Fetch the current track name while stopped' );
