
package ReSpec::Post::EBNF;

use strict;
use warnings;

our $VERSION = $ReSpec::VERSION;

sub process {
    shift;
    my $re = shift;

    my $doc = $re->outputDoc->getContextNode;
    my @snips = $re->outputDoc->findnodes('//x:pre[@class="ebnf"]/text()');
    for my $snip (@snips) {
        my $df = $doc->createDocumentFragment;
        my $txt = $snip->textContent;
        $txt =~ s/^\s+//gm;
        $df->appendChild( $doc->createTextNode($txt) );
        $snip->parentNode->replaceChild( $df, $snip );
    }
}

1;
__END__

=head1 NAME

ReSpec::Pre::EBNF - Post-processor to beautify EBNF

=head1 SYNOPSIS

  ReSpec::Pre::EBNF->process($re);

=head1 DESCRIPTION

This is a post-processor plugin that will take modify the output so that
pre elements that contain EBNF are beautified. Currently it does very
little, but future plans include adding links between grammatical tokens.

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
