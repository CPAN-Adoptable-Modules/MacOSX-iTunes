#!/usr/bin/perl
# $Id$
use strict;

use lib qw(blib/lib);

use Mac::iTunes::Library::Parse;

my $library = '/Users/brian/Music/iTunes/iTunes 3 Music Library';

my $iTunes = Mac::iTunes->read( $library );

my $playlist = $iTunes->get_playlist( 'Library' );

foreach my $item ( $playlist->items )
	{
	print $item->title, "\n";
	}
