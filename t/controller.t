# $Id$

use Test::More tests => 1;

use Mac::iTunes;

my $controller = Mac::iTunes->controller;
isa_ok( $controller, 'Mac::iTunes::AppleScript' );

