package Mac::iTunes::Library::Plist;
use strict;

=head1 NAME

Mac::iTunes::Library::Plist - interact with the music library plist file

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

brian d foy, E<lt>bdfoy@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2002, brian d foy, All rights reserved.

You may use this software under the same terms as Perl 
itself.

=cut

use Mac::PropertyList;

sub parse_file($)
	{
	my $filename = shift;
	
	open $fh, $filename or return;
	my $string = do { local $/; <$fh> };
	close $fh;
	
	parse( \$string );
	}
	
sub parse($)
	{
	my $string = shift;
	
	my $plist = Mac::PropertyList::parse_plist($string);
	}
	

"See why 1984 won't be like 1984";
