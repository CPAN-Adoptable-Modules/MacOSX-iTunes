# $Id$
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		    => 'MacOSX::iTunes',
    'VERSION_FROM'	=> 'lib/iTunes.pm',

    'PM'            => {
    	'lib/iTunes.pm'     => '$(INST_LIBDIR)/iTunes.pm',
    	'lib/Playlist.pm'   => '$(INST_LIBDIR)/iTunes/Playlist.pm',
    	'lib/Item.pm'       => '$(INST_LIBDIR)/iTunes/Item.pm',
    	'lib/Parse.pm'      => '$(INST_LIBDIR)/iTunes/Library/Parse.pm',
    	'lib/Write.pm'      => '$(INST_LIBDIR)/iTunes/Library/Write.pm',
    	},
    	
	);
