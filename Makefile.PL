# $Id$
use ExtUtils::MakeMaker;

open IN,  "mp3/iTunes_Music_Library";
open OUT, "> mp3/iTunes Music Library";

print OUT do { local $/; <IN> };

use Test::Manifest qw(get_t_files);

WriteMakefile(
    'NAME'		    => 'Mac::iTunes',
	'VERSION'       => '0.6_01',
	
    'PM'            => {
     	'lib/AppleScript.pm'  => '$(INST_LIBDIR)/iTunes/AppleScript.pm',
    	'lib/Item.pm'         => '$(INST_LIBDIR)/iTunes/Item.pm',
	   	'lib/iTunes.pm'       => '$(INST_LIBDIR)/iTunes.pm',
    	'lib/Parse.pm'        => '$(INST_LIBDIR)/iTunes/Library/Parse.pm',
    	'lib/Playlist.pm'     => '$(INST_LIBDIR)/iTunes/Playlist.pm',
    	'lib/Preferences.pm'  => '$(INST_LIBDIR)/iTunes/Preferences.pm',
    	'lib/Write.pm'        => '$(INST_LIBDIR)/iTunes/Library/Write.pm',
    	'doc/file_format.pod' => '$(INST_LIBDIR)/iTunes/FileFormat.pm',
    	},

	'PREREQ_PM' => {
		File::Find::Rule  => undef,
		Mac::AppleScript  => undef,
		Mac::PropertyList => undef,
		Test::Manifest    => undef,
		Test::More        => undef,
		Test::Pod         => undef,
		},
		    	
    test   => { TESTS      => scalar get_t_files() },
    depend => { 'Makefile' => 't/test_manifest' },
    clean  => { FILES      => q|"mp3/iTunes Music Library"| },
    	
	);
