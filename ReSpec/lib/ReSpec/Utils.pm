
package ReSpec::Utils;
use base qw(Exporter);

our @EXPORT_OK = qw(simpleGetAttr childElements addText createElement removeChildren appendElement removeTextChildren);
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK);

use XML::LibXML::Common qw(:w3c);

sub simpleGetAttr {
    my $el = shift;
    my @attr = @_;
    
    my @names;
    my %defs;
    for my $at (@attr) {
        if ($at =~ m/^(\w+)=(.+)$/) {
            push @names, $1;
            $defs{$1} = $2;
        }
        else {
            push @names, $at;
        }
    }
    my %res = map { $_ => $el->getAttributeNS(undef, $_) } @names;
    for my $n (keys %defs) {
        $res{$n} = $defs{$n} unless $res{$n};
    }
    return %res;
}

sub childElements {
    my $el = shift;
    return grep { $_->nodeType == ELEMENT_NODE } $el->childNodes;
}

sub addText {
    my $df = shift;
    my $txt = shift;
    $df->appendChild($df->ownerDocument->createTextNode( $txt ));
}

sub createElement {
    my $doc = shift;
    my $ns = shift;
    my $qn = shift;
    my $attr = shift; # only does no ns for now
    my $cnt = shift;
    
    my $el = $doc->createElementNS($ns, $qn);
    while (my ($k,$v) = each %$attr) {
        $el->setAttributeNS(undef, $k, $v);
    }
    if (ref $cnt) {
        $el->appendChild($cnt);
    }
    else {
        $el->appendChild($doc->createTextNode($cnt));
    }
    return $el;
}

sub appendElement {
    my $n = shift;
    my @rest = @_;
    my $el = createElement($n->ownerDocument, @rest);
    $n->appendChild($el);
}

sub removeChildren {
    my $node = shift;
    $node->removeChild($_) for $node->childNodes;
}

sub removeTextChildren {
    my $node = shift;
    for my $n ($node->childNodes) {
        $node->removeChild($n) if $n->nodeType == TEXT_NODE;
    }
}

1;
