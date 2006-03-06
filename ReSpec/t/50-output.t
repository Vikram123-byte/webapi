
use strict;
use Test::More tests => 2;
use ReSpec  qw();

# prepare
my $re = ReSpec->new;
$re->loadSpec('t/spec/foo.xml');
$re->loadConfig;
$re->runPreProcessors;
$re->runXSLT;
$re->runPostProcessors;

# test
#ok not(-e  $re->outputFile), "The output file does not exist";
$re->output;
ok defined $re->outputFile, "An output file has been defined";
ok -e  $re->outputFile, "The output file has been created";
unlink $re->outputFile;
