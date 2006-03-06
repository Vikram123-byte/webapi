
package ReSpec::Constants;
use base qw(Exporter);

use constant NS         => 'http://berjon.com/ns/re-spec/';
use constant XML_NS     => 'http://www.w3.org/XML/1998/namespace';
use constant RNG_NS     => 'http://relaxng.org/ns/structure/1.0';
use constant XHTML_NS   => 'http://www.w3.org/1999/xhtml';

@EXPORT_OK = qw(NS XML_NS RNG_NS XHTML_NS);
%EXPORT_TAGS = ( 'ns' => \@EXPORT_OK);

1;
