#!/usr/bin/perl
# $Id$
use strict;

$ENV{ITUNES_DEBUG} = 1;

use Data::Dumper;
use lib qw(blib/lib);

use Mac::iTunes::Library::Parse;

my $library = '/Users/brian/Music/iTunes/iTunes 3 Music Library';

my $iTunes = Mac::iTunes->read( $library );

my $playlist = $iTunes->get_playlist( 'Library' );

print Data::Dumper::Dumper( $playlist );
