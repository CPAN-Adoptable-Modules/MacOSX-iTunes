#!/usr/bin/perl

use Data::Dumper;
use Mac::iTunes;

my $library = Mac::iTunes->read(
	"$ENV{HOME}/Music/iTunes/iTunes 3 Music Library" );
	
foreach my $name ( $library->playlists )
	{
	my $playlist = $library->get_playlist( $name );
	
	print "There are " . $playlist->items . " items in $name\n";
	
	foreach my $item ( $playlist->items )
		{
		$Artists{ $item->artist }++;
		}	
	}
	
foreach my $artist ( keys %Artists )
	{
	print "$artist $Artists{$artist}\n";
	}