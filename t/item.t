# $Id$

use Test::More tests => 7;

use Mac::iTunes::Item;

my $item;

my $file   = 'mp3/The_Wee_Kirkcudbright_Centipede.mp3';
my $Title  = 'The Wee Kirkcudbright Centipede';
my $Genre  = '';
my $Artist = 'The Tappan Sisters';
my $Time   = 186.82775;

# can we create an item?
isa_ok( $item = Mac::iTunes::Item->new_from_mp3( $file ), 'Mac::iTunes::Item' );
is( $Title,  $item->title,   'Item title' );
is( $Genre,  $item->genre,   'Item genre' );
is( $Artist, $item->artist,  'Item artist' );
is( $Time,   $item->seconds, 'Item seconds' );
is( $file,   $item->file,    'Item file' );

# can we not create an item?
ok( Mac::iTunes::Item->new_from_mp3( 'foo.mp' ) == 0, 
	'Do not make item from missing file' );

