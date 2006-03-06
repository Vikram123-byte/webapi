
use strict;
use Test::More tests => 7;
use ReSpec  qw();
use ReSpec::Constants  qw(:ns);

# prepare
my $re = ReSpec->new;
$re->loadSpec('t/spec/foo.xml');
$re->loadConfig;
$re->runPreProcessors;

# test
ok not(defined $re->outputDoc), "no output so far";
$re->runXSLT;
ok defined $re->xslt, "sheet loaded";
ok UNIVERSAL::isa($re->xslt, 'XML::LibXSLT::Stylesheet'), "sheet of the right type";
ok defined $re->outputDoc, "doc is output";
ok UNIVERSAL::isa($re->outputDoc, 'XML::LibXML::XPathContext'), "doc of the right type";
my $el = $re->outputDoc->getContextNode->documentElement;
ok $el->namespaceURI eq XHTML_NS, "output is XHTML";
ok $el->localName eq 'html', "output is rooted correctly";
