
package ReTest;

use 5.008;
use strict;
use warnings;

our $VERSION = '0.1';

use Cwd                         qw(cwd);
use File::Copy                  qw(copy);

use ReTest::FS                      qw();

# load the specification
sub resourcePath {
    my $resource = shift;
    return ReTest::FS->retestToFile("retest:$resource");
}

1;
# docs are in ReTest.pod
