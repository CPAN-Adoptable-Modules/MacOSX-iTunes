# $Id$
package MacOSX::iTunes::Playlist;

sub new
	{
	my $class = shift;
	my $title = shift;
	
	my $self = { title => $title };
	
	bless $self, $class;
	
	return $self;
	}

sub title
	{
	my $self = shift;
	
	return $self->{title};
	}
	
"See why 1984 won't be like 1984";
