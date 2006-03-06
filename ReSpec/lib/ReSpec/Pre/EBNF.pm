
package ReSpec::Pre::EBNF;

use strict;
use warnings;

use ReSpec::Constants qw(:ns);

our $VERSION = $ReSpec::VERSION;

sub process {
    shift;
    my $re = shift;
    
    my @ebnf = $re->xc->findnode('//r:ebnf');
    for my $ebnf (@ebnf) {
        my @tokens = split /(\w+)\s*::=\s*/, $ebnf->textContent;
        shift @tokens;
        my @nt;
        for (my $i = 0; $i < @tokens - 1; $i += 2) {
            push @nt, $tokens[$i];
        }
        my $regex = join '|', @nt;
        for (my $i = 0; $i < @tokens - 1; $i += 2) {
            my ($key, $val) = @tokens[$i, $i+1];
            $val =~ s/\s+$//;
            # append key as a def
            # put elements in val
            # append vals
            # append \n
        }
    }

}

1;
__END__

=head1 NAME

ReSpec::Pre::EBNF - Pre-processor to handle EBNF grammars

=head1 SYNOPSIS

  ReSpec::Pre::EBNF->process($re);

=head1 DESCRIPTION

This is a pre-processor plugin that will take modify the DOM so that
EBNF get tokenized and at least partially marked up so that downstream
transformations may style them.

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
