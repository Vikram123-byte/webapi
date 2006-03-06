
package ReSpec::Post::Examples;

use strict;
use warnings;

our $VERSION = $ReSpec::VERSION;

sub process {
    shift;
    my $re = shift;

    my $doc = $re->outputDoc->getContextNode;
    my @snips = $re->outputDoc->findnodes('//x:pre[@class="example"]/text()');
    for my $snip (@snips) {
        my $txt = $snip->textContent;
        next if $txt =~ m/^\s*$/;
        $txt =~ s/\s+$//s;
        $txt =~ s/^(\s+)//;
        my $space = $1 || '';
        $space =~ m/([^\n]*)$/;
        my $ws = $1;
        $txt =~ s/^$ws//gm;
        
        my $df = $doc->createDocumentFragment;
        $df->appendChild( $doc->createTextNode($txt) );
        $snip->parentNode->replaceChild( $df, $snip );
    }
}

1;
__END__

=head1 NAME

ReSpec::Pre::Examples - Post-processor to beautify examples

=head1 SYNOPSIS

  ReSpec::Pre::Examples->process($re);

=head1 DESCRIPTION

This is a post-processor plugin that will take modify the output so that
pre elements that contain examples are beautified. Currently it does very
little, but it might do pretty printing in the future.

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
