#!/usr/bin/perl

=head1 NAME

itunes_dates.pl - convert an iTunes Music Library date

=head1 SYNOPSIS

itunes_date.pl hex_string [, hex_string]

itunes_date.pl 

=head1 DESCRIPTION

The iTunes Music Library has some wierd way of storing dates in
an integer.  I used this script to figure it out, although I
don't know what the magic number really means.

=head1 AUTHOR

brian d foy, E<lt>brian d foyE<gt>

=cut

my $offset = 2082844800 - 10 * 3600;
printf "offset is %X seconds\n", $offset;
print localtime($offset) . "\n\n"; 

foreach my $value ( map hex, @ARGV )
	{
	print  "-" x 73, "\n";
	print  "the unadjusted date:\n";
	printf "\thex %X\n\tdec %d\n", $value, $value;
	print "\t" . localtime($value) . "\n\n"; 

	my $adjusted = $value - $offset;
	print  "the adjusted date:\n";
	printf "\thex %X\n\tdec %d\n", $adjusted, $adjusted;
	print "\t" . localtime($adjusted) . "\n\n"; 
	}
