
use strict;
use Test::More tests => 4;
use ReSpec  qw();

# prepare
my $re = ReSpec->new;
$re->loadSpec('t/spec/foo.xml');
$re->loadConfig;

# test
ok $re->xc->findnodes('//r:abbr')->size == 1, "one abbr";
ok $re->xc->findnodes('//r:acronym')->size == 1, "one acronym";
ReSpec::Pre::Abbreviations->process($re);
ok $re->xc->findnodes('//r:abbr[@title = "Berjonist Alliance for Revolution"]')->size == 2, "added one abbr";
ok $re->xc->findnodes('//r:acronym[@title = "Frobnicate Other Objects"]')->size == 3, "added two acronym";
