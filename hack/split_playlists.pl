#!/usr/bin/perl

# $Id$

open my $fh, $ARGV[0] or die "Could not open [$ARGV[0]]! $!";

$/ = undef;

my $data = <$fh>;

close $fh;

($songs) = $data =~ /(htim.*)hdsm/sg;

@songs = split /(?=htim)/, $songs;
	
$data =~ /^(hdfm.*?)(hdsm.*?)(htlm.*?)(?:htim|hdsm)/s;

print "=" x 73, "\n";
print "FILE: $ARGV[0]\n";
print "\nhdfm hdsm htlm songs\n";
print   "--------------------\n";
printf "%4d %4d %4d %4d\n", (map length, $1, $2, $3), scalar @songs;

print "\nsong  len hohm    1    2    3    4    5    6    7\n";
print   "-------------------------------------------------\n";
foreach my $song ( @songs )
	{
	my @hohms = split /(?=hohm)/, $song;
	
	printf "%4d %4d %4d %4d %4d %4d %4d %4d %4d %4d\n", 
		++$count, length $song, scalar @hohms,
		map length, @hohms;
	}
	
$data =~ /.*(hdsm\000{3}\x60.*?)(hplm\000{3}\x5c.*?)hpim/;

print "\nhdsm hplm lists\n";
print   "---------------\n";
printf "%4d %4d", length $1, length $2;

$data =~ s/.*?(?=hpim)//;

@bits = split /(?=hpim)/, $data;
shift @bits;

printf " %4d\n", scalar @bits;


print "\nPlaylist    Len  Len- hpim hohm hptm songs\n";
print   "------------------------------------------\n";

foreach (@bits)
	{
	my( $name ) = m/(\w+)hptm/;
	my $l = length;
	my $n = $l - length $name;
	
	if( m/^hpim(.*?)hohm(.*?)$name(hptm.*)/s )
		{
		($l1, $l2, $l3) = map { length } ( $1, $2, $3 );
		$b3 = $3;
		@b = split /(?=hptm)/, $b3;
		
		$songs = @b;
		}

	printf "%-10s %4d %4d  %4d %4d %4d  %2d\n", $name, $l, $n, $l1, $l2, $l3, $songs;	

	}

print "=" x 73, "\n";
