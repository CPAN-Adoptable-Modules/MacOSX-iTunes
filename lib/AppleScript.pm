package Mac::iTunes::AppleScript;
use strict;

use vars qw($AUTOLOAD);

use Carp qw(carp);
use Mac::AppleScript qw(RunAppleScript);

my $Version;

=head1 NAME

Mac::iTunes::AppleScript - control iTunes from Perl

=head1 SYNOPSIS

use Mac::iTunes;

my $itunes = Mac::iTunes->controller;

$itunes->activate;
$itunes->play;
$itunes->quit;

=head1 DESCRIPTION

=head2 Methods

=over 4

=cut

my %Tell = ( 
	map( { $_, $_ } 
		qw(activate run play pause quit playpause resume rewind stop) ),
	map( { my $x = $_; $x =~ tr/_/ /; ( $_, $x ) } 
		qw(fast_forward back_track next_track previous_track) )
		);

sub AUTOLOAD
	{
	my $self   = shift;
	my $method = $AUTOLOAD;
	
	$method =~ s/.*:://g;
	
	if( exists $Tell{ $method } )
		{
		$self->tell( $Tell{ $method } );
		}
	else
		{
		carp "I didn't know what to do with [$method]";
		}	
		
	}
	
=item tell( COMMAND )

The tell() method runs a simple 

=cut

sub tell
	{
	my $self    = shift;
	my $command = shift;
	
	RunAppleScript( qq(tell application "iTunes"\n$command\nend tell) )
	}

sub DESTROY { 1 };
	
=back

=head1 SEE ALSO

=head1 AUTHOR

=cut

"See why 1984 won't be like 1984";
