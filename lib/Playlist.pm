# $Id$
package MacOSX::iTunes::Playlist;

=head1 NAME

MacOSX::iTunes::Playlist

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4 

=item new

=cut

sub new
	{
	my $class = shift;
	my $title = shift;
	
	my $self = { title => $title };
	
	bless $self, $class;
	
	return $self;
	}

=item title


=cut

sub title
	{
	my $self = shift;
	
	return $self->{title};
	}

=item items


=cut

sub items
	{
	my $self = shift;
	
	}

=item next_item


=cut

sub next_item
	{
	my $self = shift;
	
	
	}
	
=item previous_item


=cut

sub previous_item
	{
	my $self = shift;
	
	
	}
	
=item add_item


=cut

sub add_item
	{
	my $self = shift;
	
	}
	
=item delete_item


=cut

sub delete_item
	{
	my $self = shift;
	
	}
	
=item merge


=cut

sub merge
	{
	my $self = shift;
	
	}
	
=item random_item


=cut

sub random_item
	{
	my $self = shift;
	
	}
			
"See why 1984 won't be like 1984";

=back

=head1 SEE ALSO

L<MacOSX::iTunes>, L<MacOSX::iTunes::Item>

=head1 TO DO

* everything - the list of things already done is much shorter.

=head1 BUGS

=head1 AUTHOR

Copyright 2002, brian d foy <bdfoy@cpan.org>

You may redistribute this under the same terms as Perl.

=cut
