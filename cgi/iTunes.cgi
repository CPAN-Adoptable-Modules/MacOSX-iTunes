#!/usr/bin/perl
# $Id$
use strict;

use CGI qw(:standard);
use Mac::iTunes;
use Text::Template;

my $Template = '/Users/brian/Dev/MacOSX/iTunes/html/iTunes.html';

=head1 NAME

iTunes.cgi - control iTunes from the web

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

brian d foy, E<lt>bdfoy@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2002 brian d foy, All rights reserved

=cut

my $controller = Mac::iTunes->new()->controller;

my $command = param('command');

my %Commands = map { $_, 1 } qw( play stop pause );

my %var;
	
$controller->$command if exists $Commands{$command};

$var{state}   = $controller->player_state;
$var{current} = $controller->current_track_name;

my $html = Text::Template::fill_in_file( $Template, HASH => \%var );

print header(), $html, "\n";
