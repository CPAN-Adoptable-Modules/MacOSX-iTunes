#!/usr/bin/perl

use lib qw(blib/lib);

use Mac::iTunes::Library::Parse;

my $library = '/Users/brian/Music/iTunes/iTunes 3 Music Library';

my $iTunes = Mac::iTunes->new( $library );

