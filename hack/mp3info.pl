#!/usr/bin/perl
use strict;

=head1 NAME

mp3info.pl - dump the MP3 tag info for a file

=head1 SYNOPSIS

mp3info.pl FILE

=head1 DESCRIPTION

Occassionally I need to peek inside an MP3 tag to see what's there, and
this is what I use to do it.  It's not fancy, and the output isn't pretty,
but there's time for that later.  I just need the info.

=head1 AUTHOR

brian d foy, E<lt>bdfoy@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2002, brian d foy, All rights reserved

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

my $file = $ARGV[0];

foreach my $file ( @ARGV )
	{
	my $tag  = get_mp3tag($file) or die "No TAG info";
	my $info = get_mp3info($file) or die "No info";

	my $hash = { %$tag, %$info, file => $file, size => -s $file };

	print fill_in_file( $template, HASH => $hash );
	}
