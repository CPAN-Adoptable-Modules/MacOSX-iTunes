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

my $Date_offset = 2082808800;

sub _date_parse
	{
	my $integer = shift;

	return $integer if $integer < $Date_offset;

	return $integer - $Date_offset;
	}

=over 4

=item parse

Turn the iTunes Music Library into the Mac::iTunes object.

=cut

sub parse
	{
	my $class = shift;
	my $fh    = shift;

	my $data = do { local $/; <$fh> };

	print STDERR "Data length is ", length($data) . "\n" if $Debug;

	my %songs     = ();

	my $itunes = Mac::iTunes->new();

	while( $data )
		{
		$data =~ m/^(....)/;

		print STDERR "Marker is $1\n" if $Debug;

		my $marker = $1;

		my @result = $Dispatch{$marker}->( \$data );

		if( $marker eq 'htim' )
			{
			$songs{ $result[1] } = $result[0];
			}
		elsif( $marker eq 'hpim' )
			{
			my $playlist = shift @result;

			$itunes->add_playlist( $playlist );

			foreach my $song ( @result )
				{
				warn "Could not add item! [$song]" 
					unless $playlist->add_item( $songs{$song} );
				}
			}
		}

	require Data::Dumper;
	$Data::Dumper::Indent = 1;
	print STDERR Data::Dumper::Dumper( $itunes ), "\n" if $Debug;

	$itunes;	
	}

sub hdfm
	{
	my $ref = shift;
	local $Ate = 0;

	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );

	eat( $ref, 8 );

	my ($next_len) = unpack( 'S', "\000" . ${eat( $ref, 1 )} );

	my( $version ) = unpack( "A*", ${eat( $ref, $next_len )} );
	$iTunes_version = $version;

	print STDERR "\tapplication version is $version\n" if $Debug;

	eat( $ref, $length - $Ate );
	}

sub hd
	{
	my $ref = shift;
	local $Ate = 0;

	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );

	print STDERR "\thd length is $length\n" if $Debug;

	eat( $ref, $length - $Ate );
	}

=item htlm( DATA )

The htlm record holds the number of lists.  When we run into
this record, remember the right number of playlists.

=cut

sub htlm
	{
	my $ref   = shift;
	local $Ate = 0;

	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );

	my( $songs ) = unpack( "I", ${eat( $ref, 4 )} );

	print STDERR "\thtml length is $length\n" if $Debug;
	print STDERR "\tsong count is $songs\n" if $Debug;

	eat( $ref, $length - $Ate );	

	return $songs;
	}

=item htim

The htim record starts the Item object

=cut

sub htim
	{
	my $ref   = shift;

	local $Ate = 0;

	eat( $ref, 4 );

	my( $header_length ) = unpack( "I", ${eat( $ref, 4 )} );
	my( $record_length ) = unpack( "I", ${eat( $ref, 4 )} );

	my( $hohms )  = unpack( "I", ${eat( $ref, 4 )} );

	my( $id )            = unpack( "I", ${eat( $ref, 4 )} );
	my( $type )          = unpack( "I", ${eat( $ref, 4 )} );
	eat( $ref, 4 );

	my( $file_type ) = unpack( "A*", ${eat( $ref, 4 )} );
	my( $date_modified ) = _date_parse(
		unpack( "I", ${eat( $ref, 4 )} ) 
		);

	my( $bytes )  = unpack( "I", ${eat( $ref, 4 )} );
	my( $time  )  = unpack( "I", ${eat( $ref, 4 )} );

	my( $track )  = unpack( "I", ${eat( $ref, 4 )} );
	my( $tracks ) = unpack( "I", ${eat( $ref, 4 )} );

	eat( $ref, 2);

	my( $year )   = unpack( "S", ${eat( $ref, 2)} );

	eat( $ref, 2);

	my( $bit_rate )    = unpack( "S", ${eat( $ref, 2)} );
	my( $sample_rate ) = unpack( "S", ${eat( $ref, 2)} );

	eat( $ref, 2);

	my( $volume )      = unpack( "I", ${eat( $ref, 4 )} );
	my( $start )       = unpack( "I", ${eat( $ref, 4 )} );
	my( $end )         = unpack( "I", ${eat( $ref, 4 )} );
	my( $play_count )  = unpack( "I", ${eat( $ref, 4 )} );

	eat( $ref, 2);

	my( $compilation ) = unpack( "S", ${eat( $ref, 2)} );

	eat( $ref, 3*4 );

	my( $play_count2 )  = unpack( "I", ${eat( $ref, 4 )} );

	my( $play_date ) = _date_parse( unpack( "I", ${eat( $ref, 4 )} )  );
	my( $disk )      = unpack( "S", ${eat( $ref, 2)} );
	my( $disks )     = unpack( "S", ${eat( $ref, 2)} );

	my( $rating ) = unpack( "S", "\000" . ${eat( $ref, 1)} );
	eat( $ref, 11 );
	my( $add_date ) = _date_parse(
		unpack( "I", ${eat( $ref, 4 )} ) 
		);

	print  STDERR "\theader length is $header_length\n" if $Debug;
	print  STDERR "\trecord length is $record_length\n" if $Debug;
	print  STDERR "\thohms is $hohms\n" if $Debug;
	printf STDERR "\tid is %x\n", $id if $Debug;
	print  STDERR "\ttype is $type\n" if $Debug;
	print  STDERR "\tdate modified is $date_modified [" . 
		localtime($date_modified) . "]\n" if $Debug;
	print  STDERR "\tfile size is $bytes\n" if $Debug;
	print  STDERR "\tplay time is $time ms\n" if $Debug;
	print  STDERR "\ttrack is $track of $tracks\n" if $Debug;
	print  STDERR "\tyear is $year ms\n" if $Debug;
	print  STDERR "\tbit rate is $bit_rate\n" if $Debug;
	print  STDERR "\tsample rate is $sample_rate\n" if $Debug;
	print  STDERR "\tvolume adjustment is $volume\n" if $Debug;
	print  STDERR "\tstart time is $start ms\n" if $Debug;
	print  STDERR "\tend time is $end ms\n" if $Debug;
	print  STDERR "\tplay count is $play_count\n" if $Debug;
	print  STDERR "\tplay count2 is $play_count2\n" if $Debug;
	print  STDERR "\tcompilation is $compilation\n" if $Debug;
	print  STDERR "\tfile type is $file_type\n" if $Debug;
	print  STDERR "\tplay date is $play_date [" . 
		localtime($play_date) . "]\n" if $Debug;
	print  STDERR "\tdisk is $disk of $disks\n" if $Debug;
	printf STDERR "\trating is %xh [%dd] => %d stars\n", $rating, 
		$rating, $rating / 20 if $Debug;
	print  STDERR "\tadd date is $add_date\n" if $Debug;

	eat( $ref, $header_length - $Ate );

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

	eat( $ref, 4 );
	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );
	my( $type )   = unpack( "I", ${eat( $ref, 4 )} );

	print STDERR "\tlength is $length\n" if $Debug;
	print STDERR "\ttype is [$type]" if $Debug;

	print STDERR " => $hohm_types{$type}" 
		if( $Debug and exists $hohm_types{$type} );

	print STDERR "\n"  if $Debug;

	my %hohm = ( type => $type );

	my( $dl, $data );
	if( $type != 100 and $type != 1)
		{
		eat( $ref, 4 ) for 1 .. 3;

		($dl)  = unpack( "I", ${eat( $ref, 4 )} );

		eat( $ref, 4 ) for 1 .. 2;

		($data) = unpack( 'A*', ${eat( $ref, $dl )} );
		_strip_nulls( $data );

		$hohm{ $hohm_types{$type} } = $data;
		}
	elsif( $type == 1 )
		{		
		eat( $ref, 4 ) for 1 .. 3;

		eat( $ref, 2 );

		my ($next_len) = unpack( 'S', ${eat( $ref, 2 )} );
		print STDERR "\tnext length is $next_len\n" if $Debug;

		eat( $ref, $next_len );

		($next_len) = unpack( 'S', "\000" . ${eat( $ref, 1 )} );
		print STDERR "\tvolume length is $next_len\n" if $Debug;

		my ($volume) = unpack( 'A*', ${eat( $ref, $next_len )} );
		print STDERR "\tVolume is [$volume]\n" if $Debug;
		_strip_nulls( $volume );
		$hohm{volume} = $volume;
		eat( $ref, 27 - $next_len ); # ???  why 27?

		# XXX This $some_date gets stomped by the next one, so I
		# commented it out. -- Andy
		#my( $some_date ) = unpack( 'I', ${eat( $ref, 4 )} );
		my( $some_date ) = unpack( 'I', $data );

		$some_date = _date_parse( $some_date );

		print STDERR "\tsome date is [" . localtime( $some_date ) . "]\n" 
			if $Debug;

		eat( $ref, 2*4 ) if $iTunes_version =~ /^3/;

		($next_len) = unpack( 'S', "\000" . ${eat( $ref, 1 )} );
		print STDERR "\tfilename length is $next_len\n" if $Debug;

		my ($filename) = unpack( 'A*', ${eat( $ref, $next_len )} );
		print STDERR "\tfilename is [$filename]\n" if $Debug;
		_strip_nulls( $filename );
		$hohm{filename} = $filename;
		eat( $ref, 71 -  $next_len);

		my ($filetype) = unpack( 'A*', ${eat( $ref, 4 )} );
		print STDERR "\tfiletype is [$filetype]\n" if $Debug;
		_strip_nulls( $filetype );
		$hohm{filetype} = $filetype;

		my ($creator)  = unpack( 'A*', ${eat( $ref, 4 )} );
		print STDERR "\tcreator is [$creator]\n" if $Debug;
		_strip_nulls( $creator );
		$hohm{creator} = $creator;

		eat( $ref, 5 * 4 );

		($next_len) = unpack( 'I', ${eat( $ref, 4 )} );

		my ($directory) = unpack( 'A*', ${eat( $ref, $next_len )} );
		print STDERR "\tdirectory is [$directory]\n" if $Debug;
		_strip_nulls( $directory );
		$hohm{directory} = $directory;

		# i don't know what this chunk of gobbledygook is
		# the only thing i lose is my place, so i miss out
		# on parsing the path at the end.  in iTunes 3 this
		# doesn't matter so much because another hohm has
		# the URL
		while( 0 )
			{
			my( $next ) = unpack( 'A', ${eat( $ref, 1 )} );
			printf STDERR "Next char is %x\n", ord($next) if $Debug;
			next unless ( $next eq "\x5a" or $next eq "\xf7" );

			$next  = unpack( 'C', ${eat( $ref, 1 )} );
			printf STDERR "Next char is %x\n", $next if $Debug;

			$next .= unpack( 'C', ${eat( $ref, 1 )} );
			printf STDERR "Next char is %x\n", $next if $Debug;

			die unless $next eq '02';

			last;
			}

		#($next_len) = unpack( 'S', ${eat( $ref, 2 )} );

		#my ($path) = unpack( 'A*', ${eat( $ref, $next_len )} );
		#print STDERR "\tpath is [$path]\n" if $Debug;
		#$hohm{path} = $path;

		eat( $ref, $length - $Ate );
		}
	else
		{		
		eat( $ref, 3*4 );

		my ($next_len) = unpack( 'I', ${eat( $ref, 4 )} );

		eat( $ref, 2*4 );

		my ($playlist) = unpack( 'A*', ${eat( $ref, $next_len )} );
		_strip_nulls( $playlist );
		$playlist = 'Library' if $playlist eq '####!####';

		print STDERR "\tplaylist is [$playlist]\n" if $Debug;
		$hohm{playlist} = $playlist;

		eat( $ref, $length - $Ate );
		}

	print STDERR "\tdata length is $dl\n\tdata is [$data]\n" 
		unless( not $Debug or $type == 1 or $type == 100);
	#eat( $ref, $length - 4 - 4 - 4 - 4 -12 -4);

	return \%hohm;
	}

sub hplm
	{
	my $ref   = shift;

	local $Ate = 0;

	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );
	my( $lists  ) = unpack( "I", ${eat( $ref, 4 )} );

	print STDERR "\tlength is $length\n" if $Debug;
	print STDERR "\tlists is $lists\n" if $Debug;

	eat( $ref, $length - $Ate );

	return $lists;
	}

sub hpim
	{
	my $ref   = shift;

	local $Ate = 0;

	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );

	print STDERR "\tlength is $length\n" if $Debug;

	my( $foo )   = unpack( "I", ${eat( $ref, 4 )} );
	my( $hohms ) = unpack( "I", ${eat( $ref, 4 )} );
	print STDERR "\thohm blocks in playlist is $hohms\n" if $Debug;

	my( $songs ) = unpack( "I", ${eat( $ref, 4 )} );

	print STDERR "\tsongs in playlist is $songs\n" if $Debug;

	eat( $ref, $length - $Ate );

	my $playlist;
	foreach my $index ( 1 .. $hohms )
		{
		my $result = $Dispatch{'hohm'}->( $ref );
		require Data::Dumper;

		print STDERR Data::Dumper::Dumper( $result ) if $Debug;

		if( $result->{type} == 0x64 )
			{
			$playlist = Mac::iTunes::Playlist->new( $result->{playlist} );
			}
		}

	my @songs = ();
	foreach my $index ( 1 .. $songs )
		{
		my $song = $Dispatch{'hptm'}->( $ref );

		print STDERR "\tKey is $song\n" if $Debug;

		push @songs, $song;
		}

	return ( $playlist, @songs );	
	}

sub hptm
	{
	my $ref = shift;
	local $Ate = 0;

	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );
	eat( $ref, 4 );

	eat( $ref, 4*3 );

	my( $song ) = make_song_key( unpack( "I", ${eat( $ref, 4 )} ) );

	print STDERR "\tlength is $length\n" if $Debug;

	eat( $ref, $length - $Ate );

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
	my $l   = shift;
	$Ate += $l;

	my $data = substr( $$ref, 0, $l );

	substr( $$ref, 0, $l ) = '';

	\$data;
	}

sub _strip_nulls
	{
	$_[0] =~ s/\000//g;
	}

"See why 1984 won't be like 1984";

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

Copyright 2002, brian d foy, All rights reserved

You may redistribute this under the same terms as Perl.

=cut
