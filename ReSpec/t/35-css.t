
use strict;
use Test::More tests => 5;
use ReSpec  qw();
use ReSpec::Constants  qw(:ns);

# prepare
my $re = ReSpec->new;
$re->loadSpec('t/spec/foo.xml');
$re->loadConfig;
$re->runPreProcessors;
$re->runXSLT;

# insert fake
my $doc = $re->outputDoc->getContextNode;
my $head = ($re->outputDoc->findnodes('//x:head'))[0];
my $lnk = $doc->createElementNS(XHTML_NS, 'link');
$lnk->setAttributeNS(undef, 'rel',  'stylesheet');
$lnk->setAttributeNS(undef, 'href', 'foo.css');
$lnk->setAttributeNS(undef, 'type', 'text/css');
$head->appendChild($lnk);

# test
ok $re->outputDoc->findnodes("//x:link")->size == 3, "three links";
ok $re->outputDoc->findnodes("//x:style")->size == 0, "no style";
ReSpec::Post::IncludeCSS->process($re);
ok $re->outputDoc->findnodes("//x:link")->size == 1, "one link";
ok $re->outputDoc->findnodes("//x:style")->size == 2, "two styles";

my $style = ($re->outputDoc->findnodes("//x:style"))[1];
ok $style->textContent eq 'body { type: sexy; }', "style with correct content";
