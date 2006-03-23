use 5.008;
use ExtUtils::MakeMaker;

use File::Copy qw(copy);

WriteMakefile(
    NAME                => 'ReTest',
    VERSION_FROM        => 'lib/ReTest.pm', 
    ABSTRACT_FROM       => 'lib/ReTest.pod',
    EXE_FILES           => ['bin/retest'],
);
