# $Id$

use Test::More;
eval "use Test::Prereq";
plan skip_all => "Test::Prereq required for testing preqrequisites" if $@;
plan tests=>1;

print "bail out! Makefile.PL needs help!"
	unless prereq_ok( undef, undef, [qw(Mac::iTunes::FileFormat)]);
