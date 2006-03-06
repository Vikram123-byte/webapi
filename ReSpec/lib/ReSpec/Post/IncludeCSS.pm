
package ReSpec::Post::IncludeCSS;

use strict;
use warnings;

use ReSpec::FS  qw();
use ReSpec::Constants qw(:ns);

our $VERSION = $ReSpec::VERSION;

sub process {
    shift;
    my $re = shift;

    my @links = $re->outputDoc->findnodes('//x:link[@type="text/css" and not(starts-with(@href, "http"))]');
    for my $link (@links) {
        my $href = $link->getAttributeNS(undef, 'href');

        my $file;
        if ($href =~ m/^respec:/) {
            $file = ReSpec::FS->respecToFile($href);
        }
        else {
            $file = ReSpec::FS->rel2abs($href, $re->baseDir);
        }

        open CSS, "<$file" or warn "Could not find CSS '$file': $!" and next;
        my $css = do { local $/ = undef; <CSS>; };
        close CSS;

        my $doc = $re->outputDoc->getContextNode;
        my $style = $doc->createElementNS(XHTML_NS, 'style');
        $style->setAttributeNS(undef, 'type', 'text/css');
        $style->appendChild( $doc->createTextNode($css) );
        $link->parentNode->replaceChild($style, $link);
    }
}

1;
__END__

=head1 NAME

ReSpec::Pre::IncludeCSS - Post-processor to insert external CSS

=head1 SYNOPSIS

  ReSpec::Pre::IncludeCSS->process($re);

=head1 DESCRIPTION

This is a post-processor plugin that will take modify the output so that
any locally linked CSS file will be inserted into the XHTML in a style
element instead of a link element.

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
