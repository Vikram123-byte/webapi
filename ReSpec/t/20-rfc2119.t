
use strict;
use Test::More tests => 2;
use ReSpec  qw();

# prepare
my $re = ReSpec->new;
$re->loadSpec('t/spec/foo.xml');
$re->loadConfig;

# test
ok $re->xc->findnodes('//r:rfc2119')->size == 0, "no rfc2119";
ReSpec::Pre::RFC2119->process($re);
ok $re->xc->findnodes('//r:rfc2119')->size == 2, "rfc2119 added (3)";
