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

use MP3::Info;
use Data::Dumper;

my $file = $ARGV[0];

my $tag  = get_mp3tag($file) or die "No TAG info";
my $info = get_mp3info($file) or die "No info";

print Data::Dumper::Dumper( $tag, $info );
