# $Id$

use Test::More tests => 42;

use Mac::iTunes;
use Mac::iTunes::AppleScript qw(:boolean :state :size);

my $controller = Mac::iTunes->controller;
isa_ok( $controller, 'Mac::iTunes::AppleScript' );

my %old_values;

my @properties = qw(volume mute sound_volume player_state 
		player_position EQ_enabled fixed_indexing current_visual
		visuals_enabled visual_size full_screen
		current_encoder frontmost);
		
foreach my $property ( @properties )
	{
	my $value = $controller->$property;
	$hash{$property} = $value;
	print STDERR "$property is $value\n" if $ENV{ITUNES_DEBUG} > 1;
	}

ok( $controller->activate,         'Activate iTunes'    );

SKIP: {
skip "iTunes doesn't handle frontmost correctly (yet)", 4, "set frontmost to 0";
ok( $controller->frontmost(TRUE),  'Send to background' );
is( $controller->frontmost, TRUE,  'Player is in background' );
ok( $controller->frontmost(0),     'Send to background' );
is( $controller->frontmost, FALSE, 'Player is in background' );
};

my $volume = 65;
is( $controller->volume($volume), $volume,  'Set volume'   );
is( $controller->volume,          $volume,  'Fetch volume' );
is( $controller->volume(150),         100,  'Set volume past maximum' );
is( $controller->volume(-5),            0,  'Fetch volume below minimum' );

is( $controller->mute(TRUE),  TRUE,  'Set mute on'   );
is( $controller->mute,        TRUE,  'Fetch mute while on' );
is( $controller->mute(FALSE), FALSE, 'Set mute off' );
is( $controller->mute,        FALSE, 'Fetch mute while off' );

ok( $controller->stop,           'Stop controller'   );
is( $controller->state, STOPPED, 'Player is stopped' );
ok( $controller->play,           'Play controller'   );
is( $controller->state, PLAYING, 'Player is playing' );
sleep 3;
ok( $controller->pause,          'Pause controller'  );
is( $controller->state, PAUSED,  'Player is paused' );
sleep 3;
ok( $controller->playpause,      'Toggle playpause to play'  );
is( $controller->state, PLAYING, 'Player is playing' );
sleep 3;
ok( $controller->playpause,      'Toggle playpause to pause'  );
is( $controller->state, PAUSED,  'Player is paused' );

ok( $controller->visuals_enabled(FALSE), 'Set visuals to false' );
is( $controller->visuals_enabled, FALSE, 'Set visuals to false' );
ok( $controller->full_screen(FALSE),     'Set full-screen to false' );
is( $controller->full_screen, FALSE,     'Full screen is false' );
ok( $controller->visuals_enabled(TRUE),  'Set visuals to true' );
is( $controller->visuals_enabled, TRUE,  'Visuals to true' );
sleep 3;
ok( $controller->full_screen(TRUE),  'Set full-screen to true' );
is( $controller->full_screen, TRUE,  'Full screen is true' );
sleep 3;
ok( $controller->full_screen(FALSE), 'Set full-screen to false' );
is( $controller->full_screen, FALSE, 'Full screen is false' );

foreach my $size ( SMALL, MEDIUM, LARGE )
	{
	ok( $controller->visual_size($size), "Set visual size to $size" );
	is( $controller->visual_size, $size, "Visual size is $size" );
	sleep 3;
	}
	
ok( $controller->visuals_enabled(FALSE), 'Set visuals to false' );
is( $controller->visuals_enabled, FALSE, 'Set visuals to false' );
