#!/usr/bin/perl

use MP3::Info;
use Data::Dumper;

my $file = '/Users/brian/Desktop/iTunes/sample.mp3';

my $tag  = get_mp3tag($file) or die "No TAG info";
my $info = get_mp3info($file) or die "No info";

print Data::Dumper::Dumper( $tag, $info );
