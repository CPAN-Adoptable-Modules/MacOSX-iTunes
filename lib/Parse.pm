# $Id$
package Mac::iTunes::Library::Parse;
use strict;

use vars qw($Debug $Ate %hohm_types $iTunes_version $VERSION);

use Carp qw(carp croak);

use Mac::iTunes;
use Mac::iTunes::Item;
use Mac::iTunes::Playlist;

$VERSION = sprintf "%d.%02d", q$Revision$ =~ m/ (\d+) \. (\d+) /gx;

$Debug = $ENV{ITUNES_DEBUG} || 0;
$Ate   = 0;

my %Dispatch = (
	hdfm => \&hdfm, # header record
	hdsm => \&hd,   # header/footer start record
	htlm => \&htlm, # playlist meta data
	htim => \&htim, # a song record
	hohm => \&hohm, # general record type
	hplm => \&hplm, # footer ??? record
	hpim => \&hpim, # start of playlist
	hptm => \&hptm, # song in playlist
	);

	
=over 4

=item parse

Turn the iTunes Music Library into the Mac::iTunes object.

=cut

sub parse
	{
	my $class = shift;
	my $fh    = shift;

	my $data = do { local $/; <$fh> };

	warn "Data length is ", length($data) . "\n" if $Debug;

	my %songs     = ();

	my $itunes = Mac::iTunes->new();

	require Data::Dumper;
	$Data::Dumper::Indent = 1;
	
	while( $data )
		{
		$data =~ m/^(....)/;

		warn "Marker is $1\n" if $Debug;

		my $marker = $1;

		my @result = $Dispatch{$marker}->( \$data );

		if( $marker eq 'htim' )
			{
			$songs{ $result[1] } = $result[0];
			}
		elsif( $marker eq 'hpim' )
			{
			warn "There are " . @result . " items in result\n" if $Debug;
			warn Data::Dumper::Dumper( @result ), "\n" if $Debug;
			
			while( my $set = shift @result )
				{
				my $playlist = shift @$set;
				$itunes->add_playlist( $playlist );
				
				foreach my $song ( @$set )
					{
					warn "Could not add item! [$song]" 
						unless $playlist->add_item( $songs{$song} );
					}
				}
			}
		}

	warn Data::Dumper::Dumper( $itunes ), "\n" if $Debug;

	$itunes;	
	}

sub hdfm
	{
	my $ref = shift;
	local $Ate = 0;

	my $marker = _get_marker( $ref );
	my $length = _get_length( $ref );

	eat( $ref, 8 );

	my $next_len    = _get_char_int( $ref );
	$iTunes_version = _get_string( $ref, $next_len );

	warn "\tapplication version is $iTunes_version\n" if $Debug;

	_leftovers( $ref, $length );
	}

sub hd
	{
	my $ref = shift;
	local $Ate = 0;

	my $marker = _get_marker( $ref );
	my $length = _get_length( $ref );

	_next_length_debug( $length ) if $Debug;

	_leftovers( $ref, $length );
	}

=item htlm( DATA )

The htlm record holds the number of lists.  When we run into
this record, remember the right number of playlists.

=cut

sub htlm
	{
	my $ref   = shift;
	local $Ate = 0;

	my $marker = _get_marker( $ref );
	my $length = _get_length( $ref );

	my( $songs ) = _get_count( $ref );

	_next_length_debug( $length ) if $Debug;
	warn "\tsong count is $songs\n" if $Debug;

	_leftovers( $ref, $length );	

	return $songs;
	}

=item htim

The htim record starts the Item object

=cut

sub htim
	{
	my $ref    = shift;
	local $Ate = 0;

	my $marker         = _get_marker( $ref );
	my $header_length  = _get_length( $ref );
	my $record_length  = _get_length( $ref );

	my $hohms          = _get_count( $ref );
	warn "\thohms is $hohms\n" if $Debug;

	my $id             = _get_long_int( $ref );
	my $type           = _get_long_int( $ref );
	warn sprintf "\tid is %x\n\ttype is %s\n", $id, $type if $Debug;
	
	_get_long_int( $ref );
	
	my $file_type      = _get_string( $ref, 4 );
	my $date_modified  = _date_parse( _get_date( $ref ) );
	my $bytes          = _get_long_int( $ref );
	my $time           = _get_long_int( $ref );
	my $track          = _get_long_int( $ref );
	my $tracks         = _get_long_int( $ref );

	_get_short_int( $ref );
	
	my $year           = _get_short_int( $ref );

	_get_short_int( $ref );

	my $bit_rate       = _get_short_int( $ref );
	my $sample_rate    = _get_short_int( $ref );

	_get_short_int( $ref );

	my $volume         = _get_long_int( $ref );
	my $start          = _get_long_int( $ref );
	my $end            = _get_long_int( $ref );
	my $play_count     = _get_long_int( $ref );

	_get_short_int( $ref );

	my $compilation    = _get_short_int( $ref );

	eat( $ref, 3*4 );

	my $play_count2     = _get_count( $ref );

	my $play_date       = _date_parse( _get_date( $ref )  );
	my $disk            = _get_short_int( $ref );
	my $disks           = _get_short_int( $ref );

	my $rating          = _get_char_int( $ref );

	eat( $ref, 11 );

	my $add_date        = _date_parse( _get_date( $ref ) );

	warn "\tfile size is $bytes\n" if $Debug;
	warn "\tplay time is $time ms\n" if $Debug;
	warn "\ttrack is $track of $tracks\n" if $Debug;
	warn "\tyear is $year\n" if $Debug;
	warn "\tbit rate is $bit_rate\n" if $Debug;
	warn "\tsample rate is $sample_rate\n" if $Debug;
	warn "\tvolume adjustment is $volume\n" if $Debug;
	warn "\tstart time is $start ms\n" if $Debug;
	warn "\tend time is $end ms\n" if $Debug;
	warn "\tplay count is $play_count\n" if $Debug;
	warn "\tplay count2 is $play_count2\n" if $Debug;
	warn "\tcompilation is $compilation\n" if $Debug;
	warn "\tfile type is $file_type\n" if $Debug;
	warn "\tplay date is $play_date [" . 
		gmtime($play_date) . "]\n" if $Debug;
	warn "\tdisk is $disk of $disks\n" if $Debug;
	printf STDERR "\trating is %xh [%dd] => %d stars\n", $rating, 
		$rating, $rating / 20 if $Debug;
	warn "\tadd date is $add_date\n" if $Debug;

	_leftovers( $ref, $header_length );

	my %hash;
	my %songs;
	foreach my $index ( 1 .. $hohms )
		{		
		my $hohm = $Dispatch{'hohm'}->( $ref );

		foreach my $key ( keys %$hohm )
			{
			$hash{$key} = $hohm->{$key};
			}
		}

	my $item = Mac::iTunes::Item->new(
		{
		add_date      => $add_date,
		album         => $hash{album},
		artist        => $hash{artist},
		bit_rate      => $bit_rate,
		compilation   => $compilation,
		composer      => $hash{composer},
		creator       => $hash{creator},
		date_modified => $date_modified,
		directory     => $hash{directory},
		disk          => $disk,
		disks         => $disks,
		file          => $hash{filename},
		file_size     => $bytes,
		file_type     => $hash{"file type"},
		genre         => $hash{genre},
		path          => $hash{path},
		play_count    => $play_count,
		play_date     => $play_date,
		rating        => $rating,
		sample_rate   => $sample_rate,
		seconds       => $time,
		start_time    => $start,
		end_time      => $end,
		title         => $hash{title},
		track         => $track,
		tracks        => $tracks,
		url           => $hash{url},
		volume        => $hash{volume},
		year          => $year,
		}
		);

	my $key = make_song_key( $id );

	return ($item, $key);
	}

BEGIN {
%hohm_types = (
	1   => 'goobledgook',
	2   => 'title',
	3   => 'album',
	4   => 'artist',
	5   => 'genre',
	6   => 'file type',
	11  => 'url',              # version 3.0
	12  => 'composer',
	58  => 'eq_unknown',
	60  => 'eq_setting',
	100 => 'playlist',
	101 => 'smart playlist 1', # version 3.0
	102 => 'smart playlist 2', # version 3.0
	);
}

sub hohm
	{
	my $ref = shift;
	local $Ate = 0;

	my $marker   = _get_marker( $ref );
	my $eighteen = eat( $ref, 4 );

	my $length = _get_length( $ref );
	my( $type )   = _get_long_int( $ref );

	die "Record type is not defined!" unless defined $type;
	
	warn "\tlength is $length\n" if $Debug;
	warn "\t\ttype is [$type] => $hohm_types{$type}\n" if $Debug;

	my %hohm = ( type => $type );

	my( $dl, $data );
	if( $type < 100 and $type != 1 )
		{
		eat( $ref, 4 ) for 1 .. 3;

		my $next_len = _get_length( $ref );
		
		eat( $ref, 4 ) for 1 .. 2;

		($data) = unpack( 'A*', ${eat( $ref, $next_len )} );
		_strip_nulls( $data ); # XXX: unicode

		$hohm{ $hohm_types{$type} } = $data;
		}
	elsif( $type == 1 )
		{		
		_get_long_int(  $ref ) for 1 .. 3;
		_get_short_int( $ref );

		my $next_len = _get_short_int( $ref );
		warn "\t\tnext length is $next_len\n" if $Debug;

		eat( $ref, $next_len ); #???

		$next_len     = _get_char_int( $ref );
		$hohm{volume} = _get_unicode( $ref, $next_len );
		warn "\t\tvolume length is $next_len [$hohm{volume}]\n" if $Debug;

		eat( $ref, 27 - $next_len ); # ???  why 27?

		my $some_date = _date_parse( _get_date( $ref ) );
		warn "\t\tsome date is [" . _sprint_date( $some_date ) . "]\n" 
			if $Debug;

		eat( $ref, 2*4 );# if $iTunes_version =~ /^(?:3|4)/; #???

		$next_len       = _get_char_int( $ref, 1 );
		warn "\t\tnext length is $next_len\n" if $Debug;
		$hohm{filename} = _get_unicode( $ref, $next_len );
		warn "\t\tFilename is $hohm{filename}\n" if $Debug;
		
		eat( $ref, 71 - $next_len);

		$hohm{filetype} = _get_string( $ref, 4 );
		$hohm{creator}  = _get_string( $ref, 4 );
		warn "\t\tTYPE [$hohm{filetype}] CREATOR [$hohm{creator}]\n" if $Debug;

		eat( $ref, 5 * 4 );

		$next_len        = _get_long_int( $ref );
		warn "\t\tnext length is $next_len\n" if $Debug;
		$hohm{directory} = _get_unicode( $ref, $next_len ); # 0 bytes?
		}
	elsif( $type == 102 or $type == 101 )
		{
		eat( $ref, 3*4 );

		my $next_len = _get_length( $ref );
		
		$hohm{ $hohm_types{$type} } = 'Smart Playlist ' . ( $type % 100 );
		}
	else
		{		
		eat( $ref, 3*4 );

		my $next_len = _get_length( $ref );

		eat( $ref, 2*4 );

		my ($playlist) = unpack( 'A*', ${eat( $ref, $next_len )} );
		_strip_nulls( $playlist );
		$playlist = 'Library' if $playlist eq '####!####';

		warn "\tplaylist is [$playlist]\n" if $Debug;
		$hohm{ $hohm_types{$type} } = $playlist;
		}

	_leftovers( $ref, $length );
	
	return \%hohm;
	}

sub hplm
	{
	my $ref   = shift;
	local $Ate = 0;

	my $marker = _get_marker( $ref );
	my $length = _get_length( $ref );
	
	my( $lists  ) = _get_count( $ref );
	warn "\t\tlists is $lists\n" if $Debug;

	_leftovers( $ref, $length );

	return $lists;
	}

sub hpim
	{
	my $ref   = shift;
	local $Ate = 0;

	my $marker = _get_marker( $ref );
	my $length = _get_length( $ref );

	my( $foo )   = _get_long_int( $ref );
	my( $hohms ) = _get_count( $ref );
	warn "\thohm blocks in playlist is $hohms\n" if $Debug;

	my( $songs ) = _get_count( $ref );

	warn "\tsongs in playlist is $songs\n" if $Debug;

	_leftovers( $ref, $length );

	my @playlists;
	foreach my $index ( 1 .. $hohms )
		{
		my $result = $Dispatch{'hohm'}->( $ref );
		my( $name )  = grep { m/playlist/ } keys %$result;
		
		if( $result->{type} >= 0x64 )
			{
			push @playlists, 
				[ Mac::iTunes::Playlist->new( $result->{$name} ) ];
			}
		}

	my @songs = ();
	foreach my $index ( 1 .. $songs )
		{
		my $song = $Dispatch{'hptm'}->( $ref );

		warn "\tKey is $song\n" if $Debug;

		push @{ $playlists[-1] }, $song;
		}

	return @playlists;	
	}

sub hptm
	{
	my $ref = shift;
	local $Ate = 0;

	my $marker = _get_marker( $ref );
	my $length = _get_length( $ref );
	eat( $ref, 4 );

	eat( $ref, 4*3 );

	my( $song ) = make_song_key( _get_length( $ref ) );

	_leftovers( $ref, $length );

	return $song;
	}

sub make_song_key
	{
	sprintf "%08x", $_[0];
	}

sub peek
	{
	my $ref = shift;

	my $data = substr( $$ref, 0, 1 );

	sprintf "%x", unpack( "S", "\000" . $data );
	}

sub eat
	{
	my $ref = shift;
	my $l   = shift || 0;
	
	if( $l == 0 )
		{
		my @caller = caller(1);
		
		warn "Eating no bytes at $caller[3] line $caller[2]!\n"
			if( $ENV{ITUNES_DEBUG} && $caller[3] !~ m/leftovers/ );
		}
		
	$Ate += $l;

	my $data = substr( $$ref, 0, $l );

	substr( $$ref, 0, $l ) = '';

	\$data;
	}

sub _get_string    { unpack( "A*", ${eat( $_[0], $_[1] )} ) }
sub _get_long_int  { unpack( "I",  ${eat( $_[0], 4     )} ) }
sub _get_short_int { unpack( "S",  ${eat( $_[0], 2     )} ) }

sub _get_char_int  { unpack( 'S', "\000" . ${eat( $_[0], 1 )} ) }

sub _get_marker    { _get_string( $_[0], 4 )            }
sub _get_length    { _get_long_int( @_ )                }
sub _get_count     { _get_long_int( @_ )                }
sub _get_date      { _get_long_int( @_ )                }

sub _get_unicode   
	{ 
	my $s = _get_string( $_[0], $_[1] ); 
	_strip_nulls( $s ); 
	return $s; 
	}

sub _leftovers     { eat( $_[0], $_[1] - $Ate ) }
	
sub _strip_nulls
	{
	$_[0] =~ s/\000//g;
	}
	
sub _next_length_debug
	{
	my $l = shift;
	
	my @caller = caller(1);
	
	warn "  ---> next length is $l at $caller[3] line $caller[2]\n";
	}

my $Date_offset = 2082808800;

sub _date_parse
	{
	my $integer = shift;

	my $hex = sprintf "%x", $integer;
	
	return $integer if $integer < $Date_offset;

	my $time = $integer - $Date_offset;
	
	warn "\ttime is [$time|$hex] [" . _sprint_date($time) . "]\n" if $Debug;
	return $time;
	}

sub _sprint_date
	{
	my $time = shift;
	
	return scalar gmtime $time;
	}

=back

=head1 SOURCE AVAILABILITY

This source is part of a SourceForge project which always has the
latest sources in CVS, as well as all of the previous releases.

	https://sourceforge.net/projects/brian-d-foy/

If, for some reason, I disappear from the world, one of the other
members of the project can shepherd this module appropriately.

=head1 SEE ALSO

L<Mac::iTunes>, L<Mac::iTunes::Item>

=head1 TO DO

* everything - the list of things already done is much shorter.

=head1 AUTHOR

brian d foy,  E<lt>bdfoy@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2004, brian d foy, All rights reserved

You may redistribute this under the same terms as Perl.

=cut

"See why 1984 won't be like 1984";

