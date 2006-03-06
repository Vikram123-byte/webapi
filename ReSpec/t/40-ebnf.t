
use strict;
use Test::More tests => 2;
use ReSpec  qw();

# prepare
my $re = ReSpec->new;
$re->loadSpec('t/spec/foo.xml');
$re->loadConfig;
$re->runPreProcessors;
$re->runXSLT;

# test
my $txt = ($re->outputDoc->findnodes('//x:pre[@class="ebnf"]/text()'))[0]->toString;
$txt =~ s/^\n+//g;
ok $txt =~ m/^\s+/, "existing space";
ReSpec::Post::EBNF->process($re);
$txt = ($re->outputDoc->findnodes('//x:pre[@class="ebnf"]/text()'))[0]->toString;
$txt =~ s/^\n+//g;
ok $txt !~ m/^\s+/, "no more existing space";
