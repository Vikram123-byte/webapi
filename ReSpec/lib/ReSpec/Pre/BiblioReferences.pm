
package ReSpec::Pre::BiblioReferences;

use strict;
use warnings;

use ReSpec::Constants qw(:ns);
use XML::LibXML       qw();

our $VERSION = $ReSpec::VERSION;
my %biblios;

sub process {
    shift;
    my $re = shift;

    # get all defined bibrefs
    my %bibIDs = map { $_->getAttributeNS(XML_NS, 'id') => 1 } 
                 $re->xc->findnodes('//r:bibliography/r:bibentry');
    my @txts = $re->xc->findnodes('//text()');
    for my $txt (@txts) {
        my @subtxt = split /\[([A-Z][\w-]+)\]/, $txt->data;
        my $df = $re->doc->createDocumentFragment;
        while (@subtxt) {
            my $t = shift @subtxt;
            my $br = shift @subtxt if @subtxt;
            $df->appendChild($re->doc->createTextNode($t));
            if (defined $br) {
                if (exists $bibIDs{$br}) {
                    makeBibRef($re, $df, $br);
                }
                elsif (exists $biblios{$br}) {
                    my $doc = XML::LibXML->new->parse_string($biblios{$br});
                    $doc = $re->doc->adoptNode($doc->documentElement);
                    my $bibEl = ($re->xc->findnodes('//r:bibliography'))[0];
                    if (defined $bibEl) {
                        $bibEl->appendChild($doc);
                        $bibIDs{$br}++;
                        makeBibRef($re, $df, $br);
                    }
                    else {
                        warn "No <bibliography> element found, cannot auto-generate bibliography for '[$br]'.\n";
                    }
                }
                else {
                    $df->appendChild($re->doc->createTextNode("[$br]"));
                    warn "Token '[$br]' looks like a bibliographic reference but doesn't have a corresponding entry.\n";
                }
            }
        }
        $txt->parentNode->replaceChild($df, $txt);
    }
}

sub makeBibRef {
    my $re = shift;
    my $df = shift;
    my $br = shift;

    my $brel = $re->doc->createElementNS(NS, 'bibref');
    $brel->appendChild($re->doc->createTextNode($br));
    $df->appendChild($re->doc->createTextNode('['));
    $df->appendChild($brel);
    $df->appendChild($re->doc->createTextNode(']'));
}

BEGIN {
    %biblios = (
        DOM3        => q{
                        <bibentry xml:id='DOM3' xmlns='http://berjon.com/ns/re-spec/'>
                          <title>Document Object Model (DOM) Level 3 Core Specification</title>
                          <link>http://www.w3.org/TR/DOM-Level-3-Core/</link>
                          <date version='1.0'>2004-04-07</date>
                          <authors>
                            <person><name>Arnaud Le Hors</name><company>IBM</company></person>
                            <person><name>Philippe Le Hégaret</name><company>W3C</company></person>
                            <person><name>Lauren Wood</name><company>SoftQuad, Inc.</company></person>
                            <person><name>Gavin Nicol</name><company>Inso EPS</company></person>
                            <person><name>Jonathan Robie</name><company>Texcel Research and Software AG</company></person>
                            <person><name>Mike Champion</name><company>Arbortext and Software AG</company></person>
                            <person><name>Steve Byrne</name><company>JavaSoft</company></person>
                          </authors>
                        </bibentry>
        },
        DOM3EV      => q{
                        <bibentry xml:id='DOM3EV' xmlns='http://berjon.com/ns/re-spec/'>
                          <title>Document Object Model (DOM) Level 3 Events Specification</title>
                          <link>http://www.w3.org/TR/DOM-Level-3-Events/</link>
                          <date version='1.0'>2003-11-07</date>
                          <authors>
                            <person>
                              <name>Philippe Le Hégaret</name>
                              <company>W3C</company>
                            </person>
                            <person>
                              <name>Tom Pixley</name>
                              <company>Netscape Communications Corporation</company>
                            </person>
                          </authors>
                        </bibentry>
        },
        RFC1952     => q{
                        <bibentry xml:id='RFC1952' xmlns='http://berjon.com/ns/re-spec/'>
                          <title>GZIP file format specification version 4.3</title>
                          <link>http://www.ietf.org/rfc/rfc1952.txt</link>
                          <date>1996-05</date>
                          <authors>
                            <person><name>P. Deutsch</name></person>
                          </authors>
                        </bibentry>
        },
        RFC2119     => q{
                        <bibentry xml:id='RFC2119' xmlns='http://berjon.com/ns/re-spec/'>
                          <title>Key words for use in RFCs to Indicate Requirement Levels</title>
                          <link>http://www.ietf.org/rfc/rfc2119.txt</link>
                          <date>1997-01</date>
                          <authors>
                            <person><name>S. Bradner</name></person>
                          </authors>
                        </bibentry>
        },
        RFC3023     => q{
                        <bibentry xml:id='RFC3023' xmlns='http://berjon.com/ns/re-spec/'>
                          <title>XML Media Types</title>
                          <link>http://www.ietf.org/rfc/rfc3023.txt</link>
                          <date>2001-01</date>
                          <authors>
                            <person><name>M. Murata</name></person>
                            <person><name>S. St.Laurent</name></person>
                            <person><name>D. Kohn</name></person>
                          </authors>
                        </bibentry>
        },
        'QAF-SPEC'  => q{
                        <bibentry xml:id='QAF-SPEC' xmlns='http://berjon.com/ns/re-spec/'>
                          <title>QA Framework: Specification Guidelines</title>
                          <link>http://www.w3.org/TR/qaframe-spec/</link>
                          <date>2005-08</date>
                          <authors>
                            <person><name>Karl Dubost</name></person>
                            <person><name>Lynne Rosenthal</name></person>
                            <person><name>Dominique Hazaël-Massieux</name></person>
                            <person><name>Lofton Henderson</name></person>
                          </authors>
                        </bibentry>
        },
        SMIL2       => q{
                        <bibentry xml:id='SMIL2' xmlns='http://berjon.com/ns/re-spec/'>
                          <title>Synchronized Multimedia Integration Language (SMIL 2.1)</title>
                          <link>http://www.w3.org/TR/SMIL2/</link>
                          <date version='2.1'>2005-12-13</date>
                          <authors>
                            <person><name>Dick Bulterman</name><company>CWI</company></person>
                            <person><name>Guido Grassel</name><company>Nokia</company></person>
                            <person><name>Jack Jansen</name><company>CWI</company></person>
                            <person><name>Antti Koivisto</name><company>Nokia</company></person>
                            <person><name>Nabil Layaïda</name><company>INRIA</company></person>
                            <person><name>Thierry Michel</name><company>W3C</company></person>
                            <person><name>Sjoerd Mullender</name><company>CWI</company></person>
                            <person><name>Daniel Zucker</name><company>Access Co., Ltd.</company></person>
                          </authors>
                        </bibentry>
        },
        SVGT12      => q{
                        <bibentry xml:id='SVGT12' xmlns='http://berjon.com/ns/re-spec/'>
                          <title>Scalable Vector Graphics (SVG) Tiny 1.2 Specification</title>
                          <link>http://www.w3.org/TR/SVGMobile12/</link>
                          <date version='1.2'>200Y-MM-DD</date>
                          <authors>
                            <person>
                              <name>Ola Andersson</name>
                              <email>ola.andersson@ikivo.com</email>
                            </person>
                            <person>
                              <name>Robin Berjon</name>
                              <link>http://berjon.com/</link>
                              <email>robin.berjon@expway.fr</email>
                            </person>
                            <person>
                              <name>Jon Ferraiolo</name>
                              <email>jon.ferraiolo@adobe.com</email>
                            </person>
                            <person>
                              <name>Vincent Hardy</name>
                              <email>vincent.hardy@sun.com</email>
                            </person>
                            <person>
                              <name>Scott Hayman</name>
                            </person>
                            <person>
                              <name>Dean Jackson</name>
                              <link>http://www.w3.org/People/Dean/</link>
                              <email>dean@w3.org</email>
                            </person>
                            <person>
                              <name>Craig Northway</name>
                              <email>craign@cisra.canon.com.au</email>
                            </person>
                            <person>
                              <name>Antoine Quint</name>
                              <link>http://fuchsia-design.com/</link>
                              <email>aq@fuchsia-design.com</email>
                            </person>
                          </authors>
                        </bibentry>
        },
        XPATH       => q{
                        <bibentry xml:id='XPATH' xmlns='http://berjon.com/ns/re-spec/'>
                          <title>XML Path Language (XPath)</title>
                          <link>http://www.w3.org/TR/xpath</link>
                          <date version='1.0'>1999-11-16</date>
                          <authors>
                            <person>
                              <name>James Clark</name>
                              <email>jjc@jclark.com</email>
                            </person>
                            <person>
                              <name>Steve DeRose</name>
                              <email>Steven_DeRose@Brown.edu</email>
                            </person>
                          </authors>
                        </bibentry>
        },
        XML         => q{
                        <bibentry xml:id='XML' xmlns='http://berjon.com/ns/re-spec/'>
                          <p>
                            All references to XML in this specification refer to both XML 1.0 and XML 1.1.
                          </p>
                          <entry>
                            <title>Extensible Markup Language (XML) 1.0 (Third Edition)</title>
                            <link>http://www.w3.org/TR/REC-xml/</link>
                            <date version='1.1'>2004-02-04</date>
                            <authors>
                              <person>
                                <name>Tim Bray</name>
                                <email>tbray@textuality.com</email>
                              </person>
                              <person>
                                <name>Jean Paoli</name>
                                <email>jeanpa@microsoft.com</email>
                              </person>
                              <person>
                                <name>C. M. Sperberg-McQueen</name>
                                <email>cmsmcq@w3.org</email>
                              </person>
                              <person>
                                <name>Eve Maler</name>
                                <email>eve.maler@east.sun.com</email>
                              </person>
                              <person>
                                <name>François Yergeau</name>
                                <email>fyergeau@alis.com</email>
                              </person>
                            </authors>
                          </entry>
                          <entry>
                            <title>Extensible Markup Language (XML) 1.1</title>
                            <link>http://www.w3.org/TR/xml11/</link>
                            <date version='1.1'>2004-04-15</date>
                            <authors>
                              <person>
                                <name>Tim Bray</name>
                                <email>tbray@textuality.com</email>
                              </person>
                              <person>
                                <name>Jean Paoli</name>
                                <email>jeanpa@microsoft.com</email>
                              </person>
                              <person>
                                <name>C. M. Sperberg-McQueen</name>
                                <email>cmsmcq@w3.org</email>
                              </person>
                              <person>
                                <name>Eve Maler</name>
                                <email>eve.maler@east.sun.com</email>
                              </person>
                              <person>
                                <name>François Yergeau</name>
                                <email>fyergeau@alis.com</email>
                              </person>
                              <person>
                                <name>John Cowan</name>
                                <email>cowan@ccil.org</email>
                              </person>
                            </authors>
                          </entry>
                        </bibentry>
        },
        XMLEV       => q{
                        <bibentry xml:id='XMLEV' xmlns='http://berjon.com/ns/re-spec/'>
                          <title>XML Events</title>
                          <link>http://www.w3.org/TR/xml-events/</link>
                          <date version='1.0'>2003-10-14</date>
                          <authors>
                            <person>
                              <name>Shane McCarron</name>
                              <company>Applied Testing and Technology, Inc.</company>
                            </person>
                            <person>
                              <name>Steven Pemberton</name>
                              <company>CWI/W3C®</company>
                            </person>
                            <person>
                              <name>T. V. Raman</name>
                              <company>IBM Corporation</company>
                            </person>
                          </authors>
                        </bibentry>
        },
        XMLNS       => q{
                        <bibentry xml:id='XMLNS' xmlns='http://berjon.com/ns/re-spec/'>
                          <p>
                            All references to Namespaces in XML in this specification refer both to
                            versions 1.0 and 1.1, applying respectively to XML 1.0 and XML 1.1.
                          </p>
                          <entry>
                            <title>Namespaces in XML</title>
                            <link>http://www.w3.org/TR/REC-xml-names/</link>
                            <date version='1.1'>1999-01-14</date>
                            <authors>
                              <person>
                                <name>Tim Bray</name>
                                <email>tbray@textuality.com</email>
                              </person>
                              <person>
                                <name>Dave Hollander</name>
                                <email>dmh@contivo.com</email>
                              </person>
                              <person>
                                <name>Andrew Layman</name>
                                <email>andrewl@microsoft.com</email>
                              </person>
                            </authors>
                          </entry>
                          <entry>
                            <title>Namespaces in XML 1.1</title>
                            <link>http://www.w3.org/TR/xml-names11</link>
                            <date version='1.1'>2004-02-04</date>
                            <authors>
                              <person>
                                <name>Tim Bray</name>
                                <email>tbray@textuality.com</email>
                              </person>
                              <person>
                                <name>Dave Hollander</name>
                                <email>dmh@contivo.com</email>
                              </person>
                              <person>
                                <name>Andrew Layman</name>
                                <email>andrewl@microsoft.com</email>
                              </person>
                              <person>
                                <name>Richard Tobin</name>
                                <email>richard@cogsci.ed.ac.uk</email>
                              </person>
                            </authors>
                          </entry>
                        </bibentry>
        },
        XMLSpec     => q{
                        <bibentry xml:id='XMLSpec' xmlns='http://berjon.com/ns/re-spec/'>
                          <title>XML Spec</title>
                          <link>http://www.w3.org/2002/xmlspec/</link>
                          <date version='2.9'>2005-05-06</date>
                          <authors>
                            <person>
                              <name>Norman Walsh</name>
                              <email>norman.walsh@sun.com</email>
                              <url>http://nwalsh.com/people/ndw/</url>
                            </person>
                          </authors>
                        </bibentry>
        },
    );
}

1;
__END__

=head1 NAME

ReSpec::Pre::BiblioReferences - Pre-processor to add biblio references

=head1 SYNOPSIS

  ReSpec::Pre::BiblioReferences->process($re);

=head1 DESCRIPTION

This is a pre-processor plugin that will take modify the DOM so that
tokens matching [FOO] will be wrapped inside a bibref element. If there
is no matching FOO reference it will not perform the wrapping and warn.

It currently relies on a very minimal (and rather too tightly bound)
plugin framework. This is sufficient for now but will likely get 
refactored later.

Other future plans include allowing one to modify the regex that matches
tokens so that other people can use their own preferred syntax (for 
instance including spaces, as some do).

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
