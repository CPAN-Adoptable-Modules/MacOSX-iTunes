#!/usr/bin/perl -w
use strict;

use MacOSX::iTunes;

my $file = 'mp3/iTunes Music Library';
die "file [$file] does not exist\n" unless -e $file;

my $itunes = MacOSX::iTunes->read( $file );
die unless ref $itunes;

my @playlists = $itunes->playlists;

foreach my $title ( @playlists )
	{
	print "\t$title\n";
	my $playlist = $itunes->get_playlist( $title );
	
	foreach my $item ( $playlist->items )
		{
		my $title  = $item->title;
		my $artist = $item->artist;
		
		print "\t\t$title, $artist\n";
		}
	}
