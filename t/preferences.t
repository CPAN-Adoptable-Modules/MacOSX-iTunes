# $Id$

use Test::More tests => 2;

use Mac::iTunes;
use Mac::iTunes::Preferences;
use Time::HiRes;

my $file = "plists/com.apple.iTunes.plist";
my $prefs;

isa_ok( $prefs = Mac::iTunes::Preferences->parse_file( $file ), 
	'Mac::iTunes::Preferences' );

isa_ok( $prefs = Mac::iTunes->preferences( $file ), 
	'Mac::iTunes::Preferences' );