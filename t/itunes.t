# $Id$

use Test::More tests => 16;

use Mac::iTunes::Playlist;
use Mac::iTunes;

my $Title = 'Schoolhouse Rock';

my $playlist = Mac::iTunes::Playlist->new( $Title );
isa_ok( $playlist, 'Mac::iTunes::Playlist' );

my $iTunes = Mac::iTunes->new();
isa_ok( $iTunes, 'Mac::iTunes' );

ok( $iTunes->add_playlist( $playlist ),    'Add to playlist' );
ok( $iTunes->playlist_exists( $playlist ), 'Playlist exist'  );
is( $iTunes->playlists, 1,                 'Playlist count'  );

my $fetched;
ok( $fetched = $iTunes->get_playlist( $Title ),  'Fetch playlist'  );
is( $fetched, $playlist,                         'Playlist test'   );

ok( $iTunes->get_playlist( "Doesn't Exist" ) == 0, 'Non-existent playlist' );

ok( $iTunes->playlist_exists( $playlist ),      'Playlist exist before delete' );
ok( $iTunes->delete_playlist( $playlist ),      'Delete playlist' );
ok( $iTunes->playlist_exists( $playlist ) == 0, 'Playlist exists after delete' );
is( $iTunes->playlists, 0,                      'Playlist count after delete'  );

ok( $iTunes->add_playlist( ) == 0,          'Check null playlist'   );
ok( $iTunes->add_playlist( undef ) == 0,    'Check undef playlist'  );
ok( $iTunes->add_playlist( 'Title' ) == 0,  'Check string playlist' );
ok( $iTunes->add_playlist( $iTunes ) == 0,  'Check object type'     );
