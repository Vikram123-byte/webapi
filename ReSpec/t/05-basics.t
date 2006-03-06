
use strict;
use Test::More tests => 41;
use File::Spec qw();
BEGIN { use_ok('ReSpec'); }

# ctor & accessors
my $re = ReSpec->new;
ok UNIVERSAL::isa($re, 'ReSpec'), "constructor";

my %fields = (
                baseDir             => undef,
                sourceFile          => undef,
                doc                 => undef,
                xc                  => undef,
                outputDoc           => undef,
                xsltPath            => undef,
                format              => 'xhtml',
                configFile          => undef,
                Includes            => 1,
                BiblioReferences    => 1,
                RFC2119             => 1,
                Abbreviations       => 1,
                IncludeCSS          => 0,
                RelaxNG             => 1,
                EBNF                => 1,
            );

for my $acc (keys %fields) {
    if (not defined $fields{$acc}) {
        ok not(defined $re->$acc), "Accessor '$acc'";
    }
    else {
        ok $re->$acc eq $fields{$acc}, "Accessor '$acc'";
    }
}

# load a spec
$re->loadSpec('t/spec/foo.xml');
ok $re->sourceFile eq File::Spec->rel2abs('t/spec/foo.xml'), "sourceFile";
ok $re->baseDir eq File::Spec->rel2abs('t/spec'), "baseDir";
ok $re->format eq 'xhtml', "format";

ok UNIVERSAL::isa($re->doc, 'XML::LibXML::Document'), "doc";
ok UNIVERSAL::isa($re->xc, 'XML::LibXML::XPathContext'), "xc";
ok -e $re->xsltPath, "xsltPath";

# find config
ok $re->findConfig eq File::Spec->rel2abs('t/spec/respec.conf'), "findConfig";
$re->loadConfig;
ok $re->configFile eq File::Spec->rel2abs('t/spec/respec.conf'), "loadConfig";

# load config
my %opt = (
            Includes            => 1,
            BiblioReferences    => 1,
            RFC2119             => 1,
            Abbreviations       => 1,
            IncludeCSS          => 0,
            RelaxNG             => 1,
            EBNF                => 1,
            );
$re->configFile('t/spec/test.conf');
ok $re->configFile eq 't/spec/test.conf', "configFile changed";
$re->loadConfig;
for my $opt (keys %opt) {
    ok $re->$opt ne $opt{$opt}, "Config read fine for '$opt'";
}

$re->configFile(undef);
ok not(defined $re->configFile), "configFile null";
$re->loadConfig;
for my $opt (keys %opt) {
    ok $re->$opt eq $opt{$opt}, "Config read fine for '$opt'";
}



