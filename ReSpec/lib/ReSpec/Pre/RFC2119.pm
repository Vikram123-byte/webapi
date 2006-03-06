
package ReSpec::Pre::RFC2119;

use strict;
use warnings;

use ReSpec::Constants qw(:ns);

our $VERSION = $ReSpec::VERSION;

sub process {
    shift;
    my $re = shift;

    my @txts = $re->xc->findnodes('//text()');
    for my $txt (@txts) {
        my @subtxt = split /\b(
                                MUST(?:\s+NOT)?   | 
                                SHOULD(?:\s+NOT)? | 
                                MAY(?:\s+NOT)?    |
                                SHALL(?:\s+NOT)?  |
                                REQUIRED          |
                                RECOMMENDED       |
                                OPTIONAL
                            )\b/x, $txt->data;
        my $df = $re->doc->createDocumentFragment;
        while (@subtxt) {
            my $t = shift @subtxt;
            my $rfc = shift @subtxt if @subtxt;
            $df->appendChild($re->doc->createTextNode($t));
            if (defined $rfc) {
                my $rfcel = $re->doc->createElementNS(NS, 'rfc2119');
                $rfcel->appendChild($re->doc->createTextNode($rfc));
                $df->appendChild($rfcel);
            }
        }
        $txt->parentNode->replaceChild($df, $txt);
    }
}

1;
__END__

=head1 NAME

ReSpec::Pre::RFC2119 - Pre-processor to wrap RFC 2119 keywords

=head1 SYNOPSIS

  ReSpec::Pre::RFC2119->process($re);

=head1 DESCRIPTION

This is a pre-processor plugin that will take modify the DOM so that
RFC 2119 keywords will get wrapped in a rfc2119 element, allowing
downstream style sheets to handle them.

It currently relies on a very minimal (and rather too tightly bound)
plugin framework. This is sufficient for now but will likely get 
refactored later.

=head1 METHODS

=over 4

=item process $re

Takes the ReSpec object on which to operate. Returns nothing.

=back

=head1 AUTHOR

Robin Berjon, E<lt>robin.berjon@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Robin Berjon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
