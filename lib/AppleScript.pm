package Mac::iTunes::AppleScript;
use strict;

use base qw(Exporter);
use vars qw($AUTOLOAD @EXPORT_OK %EXPORT_TAGS);

use Carp qw(carp);
use Mac::AppleScript qw(RunAppleScript);

my $Singleton = undef;
@EXPORT_OK = qw(TRUE FALSE PLAYING STOPPED PAUSED SMALL MEDIUM LARGE);
%EXPORT_TAGS = (
	boolean => [ qw(TRUE FALSE) ],
	state   => [ qw(PLAYING STOPPED PAUSED) ],
	size    => [ qw(SMALL MEDIUM LARGE) ],
	);
	
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

# %Tell holds simple methods for AUTOLOAD
my %Tell = ( 
	map( { $_, $_ } 
		qw(activate run play pause quit playpause resume rewind stop) ),
	map( { my $x = $_; $x =~ tr/_/ /; ( $_, $x ) } 
		qw(fast_forward back_track next_track previous_track) )
		);
@Tell{ qw(next previous redo) } = 
	@Tell{ qw(next_track previous_track back_track) };

my %Properties = (
	map( { $_, $_ } 
		qw(mute version volume) ),
	map( { my $x = $_; $x =~ tr/_/ /; ( $_, $x ) } 
		qw(sound_volume player_state player_position
		EQ_enabled fixed_indexing current_visual
		visuals_enabled visual_size full_screen
		current_encoder frontmost) )
		);

@Properties{ qw(volume state position) } = 
	@Properties{ qw(sound_volume player_state player_position) };

use constant TRUE   => 'true';
use constant FALSE  => 'false';
use constant SMALL  => 'small';
use constant MEDIUM => 'medium';
use constant LARGE  => 'large';

my %Boolean = map { $_, 1 } qw(mute EQ_enabled fixed_indexing
	visuals_enabled full_screen front_most);

my %Validate = (
	boolean      => \&_validate_boolean,
	volume       => \&_validate_volume,
	sound_volume => \&_validate_volume,
	);
	
sub _validate_boolean { ( $_[0] and $_[0] ne FALSE ) ? TRUE : FALSE }
sub _validate_volume 
	{
	# for some reason iTunes sets the volume to 
	# one less
	my $volume = do {
		   if( $_[0] > 100 ) { 101       }
		elsif( $_[0] <=  0 ) {   1       }
		else                 { $_[0] + 1 }
		};
	}
	
sub AUTOLOAD
	{
	my $self   = shift;
	my $value  = shift;
	
	my $method = $AUTOLOAD;
	
	$method =~ s/.*:://g;
	
	if( exists $Tell{ $method } )
		{
		$self->tell( $Tell{ $method } );
		}
	elsif( exists $Properties{ $method } and defined $value )
		{
		my $valid_value = do {
			if( exists $Boolean{$method} )
				{
				$Validate{'boolean'}->($value);
				}
			elsif( exists $Validate{$method} )
				{
				$Validate{$method}->($value);
				}
			else { $value }
			};
				
		_set_value( $Properties{ $method }, $valid_value );
		}
	elsif( exists $Properties{ $method } )
		{
		_get_value( $Properties{ $method } );
		}
	else
		{
		carp "I didn't know what to do with [$method]";
		return;
		}	
		
	}

=item new()

Returns a singleton object that can control iTunes.

=cut

sub new
	{
	my $class = shift;
	
	unless( defined $Singleton )
		{
		$Singleton = bless {}, $class;
		}
		
	return $Singleton;
	}	

=item play

Start playing the current selection

=item pause

Pause playback.

=item playpause

Toggle the play-pause button.  If it's on play, it will pause, and
if it's on pause, it will play.

=item next, next_track

Skip to the next track

=item previous, previous_track

Skip to the previous track

=item redo, back_track

Go back to the start of the current track

=item stop

Stop playback.

=item fast_forward

Fast forward through the current selection.

=item rewind

Rewind through the current selection.

=item resume

Start playing after fast forward or rewind

=item quit

Quit iTunes

=item open_url( URL )

=cut

sub open_url
	{
	my $self = shift;
	my $url  = shift;
	
	$self->tell("open location $url");
	}
	
=item tell( COMMAND )

The tell() method runs a simple applescript

=cut

sub tell
	{
	my $self    = shift;
	my $command = shift;
	
	RunAppleScript( qq(tell application "iTunes"\n$command\nend tell) );
	}
	
sub _osascript
	{
	my $script = shift;
	
	print STDERR "Script is $script\n" if $ENV{ITUNES_DEBUG} > 1;
	require IPC::Open2;
	
	my( $read, $write );
	my $pid = IPC::Open2::open2( $read, $write, 'osascript' );
	
	print $write qq(tell application "iTunes"\n), $script,
		qq(\nend tell\n);
	close $write;
	
	my $data = do { local $/; <$read> };

	return $data;
	}

sub _get_value
	{
	my $property = shift;

	my $value = _osascript( "return( $property )" );
	
	chomp $value;
	
	$value;
	}

sub _set_value
	{
	my $property = shift;
	my $value    = shift;
	
	_osascript( "set $property to $value\n" );
	
	return _get_value( $property );
	}
	
sub DESTROY { 1 };

=item state

Returns the state of the iTunes application, represented by one of
the following symbolic constants:

	STOPPED
	PLAYING
	PAUSED
	FAST_FORWARDING
	REWINDING

=cut

use constant STOPPED          => 'stopped';
use constant PLAYING          => 'playing';
#use constant PAUSED           => 'paused';
use constant PAUSED           => 'stopped';
use constant FAST_FORWARDING  => 'fast forwarding';
use constant REWINDING        => 'rewinding';
	
=back
	
=head1 SEE ALSO

=head1 AUTHOR

=cut

"See why 1984 won't be like 1984";
