use 5.008;
use ExtUtils::MakeMaker;

use File::Copy qw(copy);

WriteMakefile(
    NAME                => 'ReSpec',
    VERSION_FROM        => 'lib/ReSpec.pm', 
    PREREQ_PM           => {
                            XML::LibXML                 => '',
                            XML::LibXML::XPathContext   => '',
                            XML::LibXSLT                => '',
                            },
    ABSTRACT_FROM       => 'lib/ReSpec.pod',
	EXE_FILES           => ['bin/respec'],
);

copy('../../spec/publish/Re-Spec.xhtml',  './docs/Re-Spec.xhtml');
copy('../../spec/publish/respec-w3c.css', './docs/respec-w3c.css');
