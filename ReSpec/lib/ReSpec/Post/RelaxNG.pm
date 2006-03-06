
package ReSpec::Post::RelaxNG;

use strict;
use warnings;

use ReSpec::Constants   qw(:ns);
use ReSpec::Utils       qw(:all);

our $VERSION = $ReSpec::VERSION;

sub process {
    shift;
    my $re = shift;

    my @snips = $re->outputDoc->findnodes('//rng:*[namespace-uri(..) != "' . RNG_NS . '"]');
    my $doc = $re->outputDoc->getContextNode;
    for my $snip (@snips) {
        my $parent = $snip->parentNode;
        my $df = $doc->createDocumentFragment;
        #$df->appendChild( $doc->createTextNode("\n\n") ); # this is a fix for CSS position I failed to get right
        rngToDocFrag($re, $snip, $df);
        $parent->replaceChild( $df, $snip );
    }
}

sub rngToDocFrag {
    my $re = shift;
    my $el = shift;
    my $df = shift;
    my $indent = shift || 0;
    
    my $doc = $df->ownerDocument;
    my $ws = '  ' x $indent;
    my $doEnd = 0;
    my $ln = $el->localName;
    my $ns = $el->namespaceURI;
    if ($ns eq RNG_NS) {
        if ($ln eq 'grammar') {
            my %attr = simpleGetAttr($el, qw(ns datatypeLibrary));
            $doEnd = 1;
            addText($df, "$ws<$ln ns='$attr{ns}'\n" .
                         "$ws         xmlns='" . RNG_NS . "'>\n" .
                         "$ws         datatypeLibrary='$attr{datatypeLibrary}'>\n"
                         );
        }
        elsif ($ln eq 'ref') {
            my %attr = simpleGetAttr($el, qw(name));
            addText($df, "$ws<$ln name='");
            addRngRef($df, $attr{name});
            addText($df, "'/>\n");
        }
        elsif ($ln eq 'define') {
            $doEnd = 1;
            my %attr = simpleGetAttr($el, qw(name combine));
            addText($df, "$ws<$ln name='");
            addRngAnchor($df, $attr{name});
            addText($df, "'");
            addText($df, " combine='$attr{combine}'") if $attr{combine};
            addText($df, ">\n");
        }
        elsif ($ln eq 'element' or $ln eq 'attribute') {
            $doEnd = 1;
            my %attr = simpleGetAttr($el, qw(name));
            addText($df, "$ws<$ln name='");
            $df->appendChild( createElement($df->ownerDocument, XHTML_NS, 'strong', {}, $attr{name}) );
            addText($df, "'>\n");
        }
        elsif ($ln eq 'value') {
            addText($df, "$ws<$ln>" . $el->textContent . "</$ln>\n");
        }
        elsif ($ln eq 'empty' or $ln eq 'text') {
            addText($df, "$ws<$ln/>\n");
        }
        elsif ($ln eq 'data') {
            my %attr = simpleGetAttr($el, qw(type));
            addText($df, "$ws<$ln type='$attr{type}'/>\n");
        }
        elsif ($ln eq 'div') {
            rngToDocFrag($re, $_, $df, $indent) for childElements($el);
        }
        elsif ($ln eq 'start' or $ln eq 'optional' or $ln eq 'oneOrMore' or $ln eq 'zeroOrMore' or 
               $ln eq 'zeroOrOne' or $ln eq 'choice' or $ln eq 'interleave' or $ln eq 'group') {
            $doEnd = 1;
            addText($df, "$ws<$ln>\n");
        }
        else {
            warn "Unknown element '$ln' in RelaxNG snippet, skipping.\n";
        }
    }
    else {
        warn "Unknown element '{$ns}$ln' in RelaxNG snippet, skipping.\n";
    }
    
    if ($doEnd) {
        rngToDocFrag($re, $_, $df, $indent + 1) for childElements($el);
        addText($df, "$ws</$ln>\n");
    }
}

# helpers
sub addRngRef {
    my $df = shift;
    my $name = shift;
    $df->appendChild( createElement($df->ownerDocument, 
                                    XHTML_NS, 
                                    'a', 
                                    {
                                        href    => "#rng-$name", 
                                        class   => 'rngref',
                                        title   => "Reference to the |$name| definition",
                                    }, 
                                    $name) );
}

sub addRngAnchor {
    my $df = shift;
    my $name = shift;
    $df->appendChild( createElement($df->ownerDocument, 
                                    XHTML_NS, 
                                    'a', 
                                    {
                                        class   => 'rngref',
                                        title   => "Definition of |$name|",
                                        id      => "rng-$name",
                                    }, 
                                    $name) );
}


1;
__END__

=head1 NAME

ReSpec::Pre::RelaxNG - Post-processor to beautify RelaxNG

=head1 SYNOPSIS

  ReSpec::Pre::RelaxNG->process($re);

=head1 DESCRIPTION

This is a post-processor plugin that will take modify the output so that
pre elements that contain RelaxNG are beautified. Currently it does
little more than indent and add some links, and support for RelaxNG
isn't complete, but this is meant to evolve.

It currently relies on a very minimal (and rather too tightly bound)
plugin framework. This is sufficient for now but will likely get 
refactored later.

=head1 METHODS

=over 4

=item process $re

Takes the ReSpec object on which to operate. Returns nothing.

=back

=head1 INTERNAL FUNCTIONS

=over 4

=item rngToDocFrag($re, $snip, $df);

Takes the ReSpec object (for context), a RelaxNG snippet that is an element,
and a DocumentFragment. Turns the snippet into text and XHTML elements that
are added to the DocumentFragment.

=item simpleGetAttr($el, @attrs);

Returns a hash with the given attributes as key/value pairs.

=item addText($df, $txt)

Creates a text node with $txt as its content and adds it to the $df
DocumentFragment.

=item addRngRef($df, $refName);

Creates a link to the given RelaxNG named anchor.

=item childElements $el

Takes an element and returns its descendents that are elements.

=item addRngAnchor($df, $name)

Takes a DocumentFragment and a name and creates an anchor  that RelaxNG
references can link to.

=item createElement($doc, $ns, $qn, \%attr, $content)

Creates an element belonging to $doc, with namespace and QName $ns and
$qn, and with attributes that are the keys and values of the hash (namespaced
attributes aren't supported yet). If $content is a reference it is added
as a child with the assumption that it's a node, otherwise it is added
as text content.

=back

=head1 AUTHOR

Robin Berjon, E<lt>robin.berjon@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Robin Berjon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
