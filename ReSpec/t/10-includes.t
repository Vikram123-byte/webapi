
use strict;
use Test::More tests => 4;
use ReSpec  qw();

# prepare
my $re = ReSpec->new;
$re->loadSpec('t/spec/foo.xml');
$re->loadConfig;

# test
ok $re->xc->findnodes('//r:include')->size == 2, "includes to process";
ReSpec::Pre::Includes->process($re);
ok $re->xc->findnodes('//r:include')->size == 0, "no includes left";
ok $re->xc->findnodes('//r:section[@xml:id = "inc"]')->size == 1, "files were included";
ok $re->xc->findnodes('//rng:div[@xml:id = "foo"]')->size == 1, "files were included with ID";
