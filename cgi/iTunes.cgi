#!/usr/bin/perl
# $Id$
use strict;

use CGI qw(:standard);
use Mac::iTunes;
use Text::Template;

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
	
$controller->$command if exists $Commands{$command};

my $html = 'placeholder';

print header(), $html;
