
package ReSpec;

use 5.008;
use strict;
use warnings;

#### UNTESTED FEATURES
# These features are used in practice but are not currently in the
# unit tests.
#   - exceptions (and various error conditions)
#   - warnings
#   - Output directive
#   - OutputDependencies directive
#   - ... now a bunch of others, this needs a sanity check since the last
#     sequence of test writing
####

our $VERSION = '0.53';

use XML::LibXML                 qw();
use XML::LibXML::XPathContext   qw();
use XML::LibXSLT                qw();
use Cwd                         qw(cwd);
use File::Copy                  qw(copy);

use ReSpec::FS                      qw();
use ReSpec::Constants               qw(:ns);
use ReSpec::Pre::Includes           qw();
use ReSpec::Pre::BiblioReferences   qw();
use ReSpec::Pre::RFC2119            qw();
use ReSpec::Pre::Abbreviations      qw();
use ReSpec::Pre::IDL                qw();
use ReSpec::Post::IncludeCSS        qw();
use ReSpec::Post::RelaxNG           qw();
use ReSpec::Post::EBNF              qw();
use ReSpec::Post::Examples          qw();

our %NS = (
            r   => NS,
            x   => XHTML_NS,
            rng => RNG_NS,
);

my %boolOpts = (
                Includes            => 1,
                BiblioReferences    => 1,
                RFC2119             => 1,
                Abbreviations       => 1,
                IncludeCSS          => 0,
                RelaxNG             => 1,
                EBNF                => 1,
                Examples            => 1,
                OutputDependencies  => 0,
                IDL                 => 1,
);

my %defaultOps = (
                    format  => 'xhtml',
                 );

# simple ctor
sub new {
    my $class = shift;
    return bless { %boolOpts, %defaultOps }, $class;
}

# yeah, I know, Class::Accessors is better -- flog me!
for my $field (qw(baseDir sourceFile doc xc outputDoc xsltPath format configFile xslt outputFile Output), keys %boolOpts) {
    eval 'sub ' . $field . ' { @_==2 ? $_[0]->{' . $field . '} = $_[1] : $_[0]->{' . $field . '}; }';
}

# load the specification
sub loadSpec {
    my $self = shift;
    my $file = shift;

    $file = ReSpec::FS->rel2abs($file);
    my $base = ReSpec::FS->parseFilePath($file)->basePath;
    $self->sourceFile($file);
    $self->baseDir($base);
    die "File must currently end in '.xml'" if $file !~ m/\.xml$/;
    
    $self->doc( XML::LibXML->new->parse_file($file) );
    $self->xc( XML::LibXML::XPathContext->new($self->doc) );
    $self->xc->registerNs($_, $NS{$_}) for keys %NS;

    # pick stylesheet
    my $type = $self->xc->findvalue('/r:*/r:metadata/r:styling/@type');
    my $format = $self->format;
    my $xsltPath = ReSpec::FS->respecToFile("respec:$type-$format.xslt");
    die "No XSLT for type '$type' and format '$format' at '$xsltPath'\n" unless -e $xsltPath;
    $self->xsltPath($xsltPath);
}

# load the config
sub loadConfig {
    my $self = shift;
    
    $self->configFile( $self->findConfig ) unless $self->configFile;
    $self->parseConfig;
}

# find the config
sub findConfig {
    my $self = shift;
    
    # cur dir, spec dir, home, /etc
    my $fn = 'respec.conf';
    for my $dir (cwd, $self->baseDir, $ENV{HOME}, '/etc') {
        next unless defined $dir and length $dir;
        my $path = ReSpec::FS->parseDirPath($dir);
        $path->file($fn);
        my $try = $path->path;
        return $try if -e $try;
    }
    return undef;
}

# parse the config
sub parseConfig {
    my $self = shift;
    
    my $file = $self->configFile;
    return unless defined $file and -e $file;
    
    open CONFIGURATION, "<$file" or die "Can't read file '$file': $!";
    while (my $line = <CONFIGURATION>) {
        chomp $line;
        next if $line =~ m/^\s*$/;
        next if $line =~ m/^\s*#/;
        $line =~ m/^\s*(\w+)\s+(.*)/;
        my ($cmd, $prms) = ($1, $2);
        # now the 'switch'
        if ($cmd eq 'Version') {
            die "Unsupported version '$prms'" if $prms + 0 > 1.0;
        }
        elsif (exists $boolOpts{$cmd}) {
            $self->$cmd( $prms =~ m/^\s*on\s*$/i ? 1 : 0 );
        }
        elsif ($cmd eq 'Format') {
            $prms =~ s/\s+//g;
            $self->format($prms);
        }
        elsif ($cmd eq 'Output') {
            my @prms = grep !/^\s*$/, split /\s+/, $prms;
            unshift @prms, 'File' if @prms == 1;
            die "Parameters to Output are [File|Dir] path" if @prms != 2;
            $self->Output( \@prms );
        }
        else {
            die "Unknown configuration directive '$cmd'";
        }
    }
    close CONFIGURATION;
}

# pre-processors
sub runPreProcessors {
    my $self = shift;

    for my $proc (qw(Includes BiblioReferences RFC2119 Abbreviations IDL)) {
        "ReSpec::Pre::$proc"->process($self) if $self->$proc;
    }
}

# XSLT
sub runXSLT {
    my $self = shift;
    my %prm = @_;

    my $proc = XML::LibXSLT->new;
    $self->xslt($proc->parse_stylesheet_file($self->xsltPath));
    $self->outputDoc( XML::LibXML::XPathContext->new($self->xslt->transform($self->doc, %prm)) );
    $self->outputDoc->registerNs($_, $NS{$_}) for keys %NS;
}

# post-processors
sub runPostProcessors {
    my $self = shift;

    for my $proc (qw(IncludeCSS RelaxNG EBNF Examples)) {
        "ReSpec::Post::$proc"->process($self) if $self->$proc;
    }
}

# output handling
sub output {
    my $self = shift;
    
    # figure out the output file
    if (defined $self->outputFile) {}
    elsif (defined $self->Output) {
        if ($self->Output->[0] eq 'File') {
            $self->outputFile($self->Output->[1]);
        }
        elsif ($self->Output->[0] eq 'Dir') {
            my $dir = ReSpec::FS->parseDirPath( ReSpec::FS->rel2abs($self->Output->[1], $self->baseDir) );
            my $file = ReSpec::FS->parseFilePath($self->sourceFile)->file;
            $file =~ s/\.xml$/'.' . $self->format/e;
            $dir->file($file);
            $self->outputFile($dir->path);
        }
        else {
            die "Unkown Ouput configuration: " . $self->Output->[0];
        }
    }
    else {
        my $out = $self->sourceFile;
        $out =~ s/\.xml$/'.' . $self->format/e;
        $self->outputFile($out);
    }
    
    # dependencies
    if ($self->OutputDependencies) {
        # handle moving over respec: files
        for my $lnk ($self->outputDoc->findnodes('//x:link')) {
            my $href = $lnk->getAttributeNS(undef, 'href');
            next unless $href =~ m/^respec:/;
            my $from = ReSpec::FS->respecToFile($href);
            warn "Respec resource '$href' nor found" and next unless -e $from;
            
            my $toDir = ($self->Output->[0] eq 'Dir') ? $self->Output->[1] : 
                                                        $self->baseDir;
            $href =~ s/^respec://;
            copy($from, "$toDir/$href");
            $lnk->setAttributeNS(undef, 'href', $href);
        }
    }
    
    $self->xslt->output_file($self->outputDoc->getContextNode, $self->outputFile);
}


1;
# docs are in ReSpec.pod
