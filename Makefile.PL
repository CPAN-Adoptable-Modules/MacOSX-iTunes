# $Id$
use ExtUtils::MakeMaker;

open IN,  "mp3/iTunes_Music_Library";
open OUT, "> mp3/iTunes Music Library";

print OUT do { local $/; <IN> };

my $tests = do {
	local @ARGV = qw(t/test_manifest);
	my $data = join " ", map {chomp; "t/$_" } <>;
	};
	
WriteMakefile(
    'NAME'		    => 'Mac::iTunes',
	'VERSION'       => '0.6_05',
	
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
		MP3::Info         => 0,
		Mac::Path::Util   => 0,
		File::Find::Rule  => 0,
		Mac::AppleScript  => 0,
		Mac::PropertyList => 0,
		Test::More        => 0,
		Test::Pod         => 0,
		Test::Prereq      => '0.05',
		Time::HiRes       => 0,
		Test::Data        => 0,
		},
		    	
    test   => { TESTS      => $tests },
    depend => { 'Makefile' => 't/test_manifest' },
    clean  => { FILES      => q|"mp3/iTunes Music Library"| },
    	
	);
