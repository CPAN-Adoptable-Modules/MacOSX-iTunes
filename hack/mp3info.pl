#!/usr/bin/perl
use strict;

use Data::Dumper;

=head1 NAME

mp3info - dump the MP3 tag info for files

=head1 SYNOPSIS

mp3info FILE [, FILE, ...]

=head1 DESCRIPTION

Occassionally I need to peek inside an MP3 tag to see what's there, and
this is what I use to do it.

The script looks for the C<.mp3info.rc> configuration file in the home
directory.

The single configuration directive key is C<template> whose value is
the absolute path to a Text::Template template file.

The script passes the keys and values for MP3::Info's get_mp3tag()
and get_mp3info() functions to the template, as well as the file
name (as $file) and the file size (as $size).

=head2 Example configuration

	template	/Users/brian/.mp3info.template

=head2 Example template

This template prints out a summary for each file specified on the
command line.

	{
	join "\n\t",
			$file,
			$TITLE,
			$ARTIST,
			$SIZE,
			$size,
	}

The output for that template looks like:

	12 I'm A Believer (reprise).mp3
			I'm A Believer (reprise)
			Eddie Murphy
			1459200
			1461436

=head1 AUTHOR

brian d foy, E<lt>bdfoy@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2003, brian d foy, All rights reserved

You may use this software under the same terms as Perl itself.

=cut

use ConfigReader::Simple;
use MP3::Info;
use Text::Template qw(fill_in_file);

my $Config = "$ENV{HOME}/.mp3info.rc";

my $config = ConfigReader::Simple->new( $Config );
die "Could not get configuration" unless ref $config;

my $template = $config->template;
die "Could not find template [$template]!" unless -e $template;

foreach my $file ( @ARGV )
	{
	my $tag  = get_mp3tag($file) or die "No TAG info";
	my $info = get_mp3info($file) or die "No info";

	print Data::Dumper::Dumper( $tag, $info ) if $ENV{DEBUG};
	
	my $hash = { %$tag, %$info, file => $file, size => -s $file };

	print fill_in_file( $template, HASH => $hash );
	}
