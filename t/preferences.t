# $Id$

use Test::More tests => 1;

use Mac::iTunes;

my $prefs;
isa_ok( $prefs = Mac::iTunes->preferences, 'Mac::iTunes::Preferences' );
