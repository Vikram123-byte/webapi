
package ReSpec::Pre::Abbreviations;

use strict;
use warnings;

use ReSpec::Constants qw(:ns);

our $VERSION = $ReSpec::VERSION;

sub process {
    shift;
    my $re = shift;

    # get all defined acronyms and abbr
    my %acro = map { $_->textContent => $_->getAttributeNS(undef, 'title') } 
                 $re->xc->findnodes('//r:acronym');
    my %abbr = map { $_->textContent => $_->getAttributeNS(undef, 'title') } 
                 $re->xc->findnodes('//r:abbr');
    # acronym
    if (keys %acro) {
        my @txts = $re->xc->findnodes('//text()');
        my $acroRx = join '|', sort { length $b <=> length $a } map { "$_(?:s)?" } keys %acro;
        for my $txt (@txts) {
            next if $txt->parentNode->localName eq 'acronym';
            my @subtxt = split /\b($acroRx)\b/o, $txt->data;
            my $df = $re->doc->createDocumentFragment;
            while (@subtxt) {
                my $t = shift @subtxt;
                my $ac = shift @subtxt if @subtxt;
                $df->appendChild($re->doc->createTextNode($t));
                if (defined $ac) {
					$ac =~ s/s$//;
                    my $acel = $re->doc->createElementNS(NS, 'acronym');
                    $acel->appendChild($re->doc->createTextNode($ac));
                    $acel->setAttributeNS(undef, 'title', $acro{$ac});
                    $df->appendChild($acel);
                }
            }
            $txt->parentNode->replaceChild($df, $txt);
        }
    }

    # abbr
    if (keys %abbr) {
        my @txts = $re->xc->findnodes('//text()');
        my $abbrRx = join '|', sort { length $b <=> length $a } keys %abbr;
        for my $txt (@txts) {
            next if $txt->parentNode->localName eq 'abbr';
            my @subtxt = split /\b($abbrRx)\b/o, $txt->data;
            my $df = $re->doc->createDocumentFragment;
            while (@subtxt) {
                my $t = shift @subtxt;
                my $ab = shift @subtxt if @subtxt;
                $df->appendChild($re->doc->createTextNode($t));
                if (defined $ab) {
                    my $abel = $re->doc->createElementNS(NS, 'abbr');
                    $abel->appendChild($re->doc->createTextNode($ab));
                    $abel->setAttributeNS(undef, 'title', $abbr{$ab});
                    $df->appendChild($abel);
                }
            }
            $txt->parentNode->replaceChild($df, $txt);
        }
    }
}

1;
__END__

=head1 NAME

ReSpec::Pre::Abbreviations - Pre-processor to abbreviations and acronyms

=head1 SYNOPSIS

  ReSpec::Pre::Abbreviations->process($re);

=head1 DESCRIPTION

This is a pre-processor plugin that will take modify the DOM so that
any word marked as an abbreviation or an acronym somewhere will be
wrapped similarly for all its occurences (including plurals)
elsewhere in the text.

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
