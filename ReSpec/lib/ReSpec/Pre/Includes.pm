
package ReSpec::Pre::Includes;

use strict;
use warnings;

use ReSpec::FS  qw();

our $VERSION = $ReSpec::VERSION;

# fix
unless (defined(&XML::LibXML::Document::getElementById)) {
    *XML::LibXML::Document::getElementById = \&XML::LibXML::Document::getElementsById;
}

sub process {
    shift;
    my $re = shift;

    my @incs = $re->xc->findnodes('//r:include');
    for my $inc (@incs) {
        # parametrise templates later
        my $href = $inc->getAttributeNS(undef, 'href');
        if ($href =~ m/^respec:/) {
            die "Unknown include template type for '$href'" unless $href =~ m/\.tpl$/;
            my $tpl = XML::LibXML->new->parse_file( ReSpec::FS->respecToFile($href) );
            my $doc = $re->doc;
            my $df = $doc->createDocumentFragment;
            for my $n ($tpl->documentElement->childNodes) {
                $doc->importNode($n);
                $df->appendChild($n);
            }
            $inc->parentNode->replaceChild($df, $inc);
        }
        else {
            my $id;
            if ($href =~ m/#/) {
                ($href, $id) = split /#/, $href, 2;
            }
            my $docEl = XML::LibXML->new->parse_file( ReSpec::FS->rel2abs($href, $re->baseDir) )->documentElement;
            if (defined $id) {
                $docEl = $docEl->ownerDocument->getElementById($id);
                warn "No element with ID '$id'" and next unless $docEl;
            }
            $re->doc->importNode($docEl);
            $inc->parentNode->replaceChild($docEl, $inc);
        }
    }
}


1;
__END__

=head1 NAME

ReSpec::Pre::Includes - Pre-processor for r:include elements

=head1 SYNOPSIS

  ReSpec::Pre::Includes->process($re);

=head1 DESCRIPTION

This is a pre-processor plugin that will take modify the DOM so that
r:include elements are replaced with what they refer to.

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
