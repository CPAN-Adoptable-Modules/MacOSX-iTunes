#$Id$
use Test::More;
local $^W = 0; # don't warn about redefining subroutines
 
eval "use Test::Prereq";
plan skip_all => "Test::Prereq required to test dependencies" if $@;
plan tests => 1;
prereq_ok();
