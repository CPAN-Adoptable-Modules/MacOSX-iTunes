<<<<<<< prereq.t
#$Id$
use Test::More;
local $^W = 0; # don't warn about redefining subroutines
 
eval "use Test::Prereq";
plan skip_all => "Test::Prereq required to test dependencies" if $@;
plan tests => 1;
prereq_ok();
=======
# $Id$

use Test::More;
eval "use Test::Prereq";
plan skip_all => "Test::Prereq required for testing preqrequisites" if $@;
plan tests=>1;

print "bail out! Makefile.PL needs help!"
	unless prereq_ok( undef, undef, [qw(Mac::iTunes::FileFormat)]);
>>>>>>> 1.3
