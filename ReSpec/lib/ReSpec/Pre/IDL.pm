
package ReSpec::Pre::IDL;

use strict;
use warnings;

use ReSpec::Constants   qw(:ns);
use ReSpec::Utils       qw(:all);

our $VERSION = $ReSpec::VERSION;

sub process {
    shift;
    my $re = shift;
    
    my %allIF = map { $_->getAttributeNS(undef, 'name') => 1 } 
                $re->xc->findnodes('//r:interface | //r:exception[not(parent::r:attribute) and not(parent::r:method)]');
    removeTextChildren($_) for $re->xc->findnodes('//r:idl[r:*]');
    my @idl = $re->xc->findnodes('//r:idl/r:interface        |
                                  //r:idl/r:definition-group |
                                  //r:idl/r:attribute        |
                                  //r:idl/r:method           |
                                  //r:idl/r:exception');
    for my $obj (@idl) {
        # move the element to after <schema>
        my $idl = $obj->parentNode;
        my $sch = $idl->parentNode;
        $sch->parentNode->insertBefore($obj, $sch->nextSibling);
        $idl->normalize();

        # add everything we do to the DF
        my $doc = $re->doc;
        my $df = $doc->createDocumentFragment;
        my $indent = '';
        my $objType = $obj->localName;

        # if and mod names
        my $ifName = $obj->getAttributeNS(undef, $objType eq 'interface' ? 'name' : 'interface');
        my $ifLink = $ifName ? "$ifName-" : '';
        my $modName = $obj->getAttributeNS(undef, 'module') || '';
        my $modLink = $modName ? "$modName-" : '';

        # process depending on type
        if ($objType eq 'definition-group') {
            processDefinitionGroup($re, $obj, $df, '');
        }
        elsif ($objType eq 'attribute') {
            processAttribute($re, $obj, $df, \%allIF, $ifLink, '');
        }
        elsif ($objType eq 'method') {
            processMethod($re, $obj, $df, \%allIF, $ifLink, '');
        }
        elsif ($objType eq 'exception') {
            addText($df, 'exception ');
            my $name = $obj->getAttributeNS(undef, 'name');
            appendElement($df, NS, 'a', { href => '#idl-' . $modLink . $name }, $name);
            addText($df, " {\n  unsigned short   code;\n};\n");
        }
        elsif ($objType eq 'interface') {
            addText($df, 'interface ');
            appendElement($df, NS, 'a', { href => '#idl-' . $modLink . $ifName }, $ifName);
            addText($df, " {\n\n");
            for my $dg ($re->xc->findnodes('.//r:definition-group', $obj)) {
                processDefinitionGroup($re, $dg, $df, '  ');
                addText($df, "\n");
            }
            for my $am ($re->xc->findnodes('.//r:attribute | .//r:method', $obj)) {
                processAttribute($re, $am, $df, \%allIF, $ifLink, '  ') if $am->localName eq 'attribute';
                processMethod($re, $am, $df, \%allIF, $ifLink, '  ') if $am->localName eq 'method';
            }
            addText($df, "};");
        }
        else {
            warn "[IDL] Unknown type of IDL element '$objType'\n";
        }

        $idl->appendChild($df);
    }

}

sub getMax {
    my $max = 0;
    for my $c (@_) {
        $max = length($c) > $max ? length($c) : $max;
    }
    return $max;
}

sub addLinkIFOrText {
    my $allIF = shift;
    my $df = shift;
    my $name = shift;

    if (exists $allIF->{$name}) {
        my $a = createElement($df->ownerDocument, NS, 'a', { href => "#idl-if-$name" }, $name);
        $df->appendChild($a);
    }
    else {
        addText($df, $name);
    }
}

sub processDefinitionGroup {
    my $re = shift;
    my $dg = shift;
    my $df = shift;
    my $indent = shift;

    my $for = $dg->getAttributeNS(undef, 'for');
    addText($df, "$indent// $for\n");
    my $prevVal = -1;
    my @const = map {
                    if (not defined $_->{value}) {
                        $prevVal++;
                        $_->{value} = $prevVal;
                    }
                    else {
                        $prevVal = $_->{value};
                    }
                    $_;
                }
                map { { simpleGetAttr($_, ('name', 'value', 'type=unsigned short')) } }
                $re->xc->findnodes('./r:constant', $dg);
    # padding
    my $max = getMax( map { $_->{name} } @const) + 6;

    # now do them
    for my $c (@const) {
        addText($df, $indent . 'const ' . $c->{type} . '      ');
        appendElement($df, NS, 'a', { href => "#idl-defs-$for-" . $c->{name} }, $c->{name});
        addText($df, (' ' x ($max - length $c->{name})) . '= ' . $c->{value} . ";\n");
    }
}

sub processMethod {
    my $re = shift;
    my $meth = shift;
    my $df = shift;
    my $allIF = shift;
    my $ifLink = shift;
    my $indent = shift;

    my $maxMethType = getMax(
                          'readonly attribute',
                          map { $re->xc->findvalue('r:returns/@type', $_) || 'void' } 
                          $re->xc->findnodes('.//r:method', $meth->parentNode)
                        ) + 1;
    
    # param info
    # there is a deliberate limitation in that only one param can be of varying type
    my @allParams;
    my $seenOpt = 0;
    for my $prm ($re->xc->findnodes('r:param', $meth)) {
        my %prm = simpleGetAttr($prm, qw(name type=DOMString optional=false));
        $prm{optional} = 'true' if $seenOpt;
        $prm{optional} = $prm{optional} eq 'true' ? 1 : 0;
        $seenOpt++ if $prm{optional};
        push @allParams, \%prm;
    }
    my @params;
    while ($seenOpt >= 0) {
        my @copy = @allParams;
        if (grep { $_->{type} =~ m/\|/ } @copy) {
            my $multi = (grep { $_->{type} =~ m/\|/ } @copy)[0];
            my @opt = split /\s*\|\s*/, $multi->{type};
            for my $opt (@opt) {
                $multi->{type} = $opt;
                my @copy2 = map { { %$_ } } @copy;
                unshift @params, \@copy2;
            }
        }
        else {
            unshift @params, \@copy;
        }
        pop @allParams;
        $seenOpt--;
    }

    # common info
    my $name = $meth->getAttributeNS(undef, 'name');
    my $type = $re->xc->findvalue('r:returns/@type', $meth) || 'void';

    for my $prms (@params) {
        addText($df, '  ');
        addLinkIFOrText($allIF, $df, $type);
        addText($df, ' ' x ($maxMethType - length($type)));
        appendElement($df, NS, 'a', { href => '#dfn-' . "$name" }, $name);
        addText($df, "(");
        my $i = 1;
        for my $prm (@$prms) {
            addText($df, 'in ');
            addLinkIFOrText($allIF, $df, $prm->{type});
            addText($df, " $prm->{name}");
            addText($df, ", ") unless $i == @$prms;
            $i++;
        }                    
        addText($df, ")");
        my @ex = $re->xc->findnodes("./r:exception", $meth);
        if (@ex) {
            my $ls = join(', ', map { $_->getAttributeNS(undef, 'name') } @ex);
            addText($df, "\n" . (' ' x 38) . "${indent}raises($ls)");
        }
        addText($df, ";\n");
    }
}

sub processAttribute {
    my $re = shift;
    my $at = shift;
    my $df = shift;
    my $allIF = shift;
    my $ifLink = shift;
    my $indent = shift;
    
    my $maxAttrType = getMax(
                          map { $_->getAttributeNS(undef, 'type') || 'DOMString' } 
                          $re->xc->findnodes('.//r:attribute', $at->parentNode)
                      ) + 2;

    my %attr = simpleGetAttr($at, qw(ro=false type=DOMString name));
    $attr{ro} = $attr{ro} eq 'true' ? 1 : 0;
    addText($df, $indent . ($attr{ro} ? 'readonly' : ' ' x 8) . ' attribute ');
    addLinkIFOrText($allIF, $df, $attr{type});
    addText($df, ' ' x ($maxAttrType - length($attr{type})));
    appendElement($df, NS, 'a', { href => '#dfn-' . "$attr{name}" }, $attr{name});
    addText($df, ";\n");

    # exceptions
    for my $on (qw(setting retrieval)) {
        my @ex = $re->xc->findnodes("./r:exception[r:code[contains(\@on, '$on')]]", $at);
        if (@ex) {
            my $ls = join(', ', map { $_->getAttributeNS(undef, 'name') } @ex);
            addText($df, (' ' x 38) . "$indent// raises($ls) on $on\n");
        }
    }
}

1;
__END__

=head1 NAME

ReSpec::Pre::IDL - Pre-processor to handle our IDL ML

=head1 SYNOPSIS

  ReSpec::Pre::IDL->process($re);

=head1 DESCRIPTION

This is a pre-processor plugin that will take modify the DOM so that
the IDL markup gets changed into IDL text, while the IDL markup
is annotated (if need be) and moved out of the schema element in order
to produce some nice XHTML.

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

Copyright (C) 2006 by Robin Berjon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
