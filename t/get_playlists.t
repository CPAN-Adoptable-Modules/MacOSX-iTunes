# $Id$
use strict;

use Test::More tests => 3;

use Mac::iTunes;

my $controller = Mac::iTunes->controller;
isa_ok( $controller, 'Mac::iTunes::AppleScript' );

my $lists = $controller->get_playlists;
isa_ok( $lists, 'ARRAY' );

pass();
