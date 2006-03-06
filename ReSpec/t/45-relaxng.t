
use strict;
use Test::More tests => 3;
use ReSpec  qw();

# prepare
my $re = ReSpec->new;
$re->loadSpec('t/spec/foo.xml');
$re->loadConfig;
$re->runPreProcessors;
$re->runXSLT;

# test
ok $re->outputDoc->findnodes('//rng:div')->size == 1, "RelaxNG is present";
ReSpec::Post::RelaxNG->process($re);
ok $re->outputDoc->findnodes('//rng:div')->size == 0, "RelaxNG removed";
ok $re->outputDoc->findnodes('//x:a[@class = "rngref"]')->size > 0, "RelaxNG anchors";
