# $Id$
use strict;

use lib  qw(./t/lib ./lib);

use Test::More tests => 2;

use Mac::iTunes;

require "test_data.pl";

my $controller = Mac::iTunes->controller;
isa_ok( $controller, 'Mac::iTunes::AppleScript' );

my $lists = $controller->get_track_names_in_playlist( 
	$iTunesTest::Test_playlist );
isa_ok( $lists, 'ARRAY' );
