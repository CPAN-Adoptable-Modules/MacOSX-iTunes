#!/usr/bin/perl -w
# $Id$

my $data = do { local $/; <> };

%hash = (
	hdfm => \&hd,
	hdsm => \&hd,
	htlm => \&htlm,
	htim => \&htim,
	hohm => \&hohm,
	hplm => \&hplm,
	hpim => \&hpim,
	hptm => \&hptm,
	);
	
my $count = 0;

while( $data )
	{
	$data =~ m/^(....)/;
	
	print "Marker is $1\n";
	
	$marker = $1;
	
	$hash{$marker}->(\$data);
	}
	

sub hd
	{
	my $ref = shift;
	
	eat( $ref, 4 );
	
	my( $length ) = unpack( "I", next_u32( $ref ) );
	
	eat( $ref, 4 );
	
	print "\tlength is $length\n";
	
	eat( $ref, $length - 4 - 4 );
	}
	
sub htlm
	{
	my $ref = shift;
	
	eat( $ref, 4 );
	
	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );
	
	my( $lists ) = unpack( "I", ${eat( $ref, 4 )} );
	
	print "\tlength is $length\n";
	print "\tlists is $lists\n";
	
	eat( $ref, $length - 4 - 4 - 4 );
	}

sub htim
	{
	my $ref = shift;
	
	$Ate = 0;
	
	eat( $ref, 4 );
	
	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );
		
	eat( $ref, 4 );
	
	my( $hohms ) = unpack( "I", ${eat( $ref, 4 )} );
	
	my( $id ) = unpack( "I", ${eat( $ref, 4 )} );

	print "\tlength is $length\n";
	print "\thohms is $hohms\n";
	printf "\tid is %x\n", $id;
	
	$Last_id = sprintf "%x", $id;
	
	eat( $ref, $length - $Ate);
	}

BEGIN {
%hohm_types = (
	1 => 'goobledgook',
	2 => 'song',
	3 => 'album',
	4 => 'artist',
	5 => 'genre',
	6 => 'file type',
	100 => 'playlist',
	);
}
	
sub hohm
	{
	my $ref = shift;
	
	eat( $ref, 4 );
	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );
	my( $type )   = unpack( "I", ${eat( $ref, 4 )} );

	print "\tlength is $length\n";
	print "\ttype is [$type]";
		
	print " => $hohm_types{$type}" if exists $hohm_types{$type};
	
	print "\n";

	my( $dl, $data );
	if( $type != 100 and $type != 1)
		{
		eat( $ref, 4 ) for 1 .. 3;
	
		($dl)  = unpack( "I", ${eat( $ref, 4 )} );
	
		eat( $ref, 4 ) for 1 .. 2;
	
		($data) = unpack( 'A*', ${eat( $ref, $dl )} );
		
		$Songs{ $Last_id } = $data if $type == 2;
		}
	elsif( $type == 1 )
		{
		$Ate = 16;
		
		eat( $ref, 4 ) for 1 .. 3;
		
		eat( $ref, 2 );
		
		my ($next_len) = unpack( 'S', ${eat( $ref, 2 )} );
		print "\tnext length is $next_len\n";

		eat( $ref, $next_len );

		($next_len) = unpack( 'S', "\000".${eat( $ref, 1 )} );
		print "\tvolume length is $next_len\n";
		
		my ($volume) = unpack( 'A*', ${eat( $ref, $next_len )} );
		print "\tVolume is [$volume]\n";
		eat( $ref, 6*4 );
		
		($next_len) = unpack( 'S', "\000".${eat( $ref, 1 )} );
		print "\tfilename length is $next_len\n";

		my ($filename) = unpack( 'A*', ${eat( $ref, $next_len )} );
		print "\tfilename is [$filename]\n";
		eat( $ref, 71 -  $next_len);
	
		my ($filetype) = unpack( 'A*', ${eat( $ref, 4 )} );
		print "\tfiletype is [$filetype]\n";
		my ($creator)  = unpack( 'A*', ${eat( $ref, 4 )} );
		print "\tcreator is [$creator]\n";

		eat( $ref, 5 * 4);

		($next_len) = unpack( 'I', ${eat( $ref, 4 )} );

		my ($directory) = unpack( 'A*', ${eat( $ref, $next_len )} );
		print "\tdirectory is [$directory]\n";

		while( 1 )
			{
			my( $next ) = unpack( 'A', ${eat( $ref, 1 )} );
			next unless $next eq "\x5a";

			$next  = unpack( 'C', ${eat( $ref, 1 )} );
			$next .= unpack( 'C', ${eat( $ref, 1 )} );

			die unless $next eq '02';
						
			last;
			}
			
		($next_len) = unpack( 'S', ${eat( $ref, 2 )} );

		my ($path) = unpack( 'A*', ${eat( $ref, $next_len )} );
		print "\tpath is [$path]\n";

		eat( $ref, $length - $Ate );
		
		}
	else
		{
		$Ate = 16;
		
		eat( $ref, 3*4 );
		
		my ($next_len) = unpack( 'I', ${eat( $ref, 4 )} );

		eat( $ref, 2*4 );
		
		my ($playlist) = unpack( 'A*', ${eat( $ref, $next_len )} );
		print "\tplaylist is [$playlist]\n";
	
		eat( $ref, $length - $Ate );
		}
		
	print "\tdata length is $dl\n" unless( $type == 1 or $type == 100);
	print "\tdata is [$data]\n" unless( $type == 1 or $type == 100);
	#eat( $ref, $length - 4 - 4 - 4 - 4 -12 -4);
	}

sub hplm
	{
	my $ref = shift;
	
	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );

	print "\tlength is $length\n";

	eat( $ref, $length - 4 - 4 );
	}

sub hpim
	{
	my $ref = shift;
	
	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );

	print "\tlength is $length\n";

	eat( $ref, $length - 4 - 4 );
	}

sub hptm
	{
	my $ref = shift;
	
	$Ate = 0;
	
	eat( $ref, 4 );

	my( $length ) = unpack( "I", ${eat( $ref, 4 )} );
	eat( $ref, 4 );

	eat( $ref, 4*3 );

	my( $song ) = sprintf "%x", unpack( "I", ${eat( $ref, 4 )} );

	print "\tlength is $length\n";
	print "\tSong: $Songs{$song}\n";
	
	eat( $ref, $length - $Ate );
	}
		
sub next_u32
	{
	my $ref = shift;
	
	substr( $$ref, 0, 4 );
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
