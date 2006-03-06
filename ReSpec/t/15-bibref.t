
use strict;
use Test::More tests => 2;
use ReSpec  qw();

# prepare
my $re = ReSpec->new;
$re->loadSpec('t/spec/foo.xml');
$re->loadConfig;

# test
ok $re->xc->findnodes('//r:bibref')->size == 0, "no bibref";
ReSpec::Pre::BiblioReferences->process($re);
ok $re->xc->findnodes('//r:bibref')->size == 1, "bibref added";
