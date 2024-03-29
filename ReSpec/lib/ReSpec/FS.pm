
package ReSpec::FS;

use strict;
use warnings;

use File::Spec qw();

our $VERSION = $ReSpec::VERSION;

sub new {
    my $class = shift;
    my $path = shift;
    my $noFile = shift || 0;
    my $self = bless clear({}), $class;
    if (defined $path) {
        my $dirs;
        ($self->{volume}, $dirs, $self->{file}) = File::Spec->splitpath($path, $noFile);
        $self->{dirs} = [File::Spec->splitdir($dirs)];
    }
    #if (@{$self->{dirs}})
    return $self;
}

sub parseFilePath {
    my $class = shift;
    return $class->new(shift, 0);
}

sub parseDirPath {
    my $class = shift;
    return $class->new(shift, 1);
}

sub respecDir {
    my $class = shift;
    my $self = $class->parseFilePath($INC{'ReSpec.pm'});
    $self->file('');
    return $self;
}

sub clear {
    my $self = shift;
    $self->{volume} = '';
    $self->{dirs}   = [];
    $self->{file}   = '';
    return $self;
}

sub rel2abs {
    shift;
    return File::Spec->rel2abs(shift, shift);
}

sub path {
    my $self = shift;
    return File::Spec->catpath( $self->{volume},
                                File::Spec->catdir(@{$self->{dirs}}),
                                $self->{file});
}

sub basePath {
    my $self = shift;
    $self->file('');
    return $self->path;
}

sub file { @_==2 ? $_[0]->{file} = $_[1]: $_[0]->{file}; }
sub dirs { @_==2 ? $_[0]->{dirs} = $_[1]: $_[0]->{dirs}; }
sub volume { @_==2 ? $_[0]->{volume} = $_[1]: $_[0]->{volume}; }

sub pushDirs {
    my $self = shift;
    my @dirs = @_;
    push @{$self->dirs}, @dirs;
}

sub respecToFile {
    my $class = shift;
    my $href = shift;
    return unless $href =~ m/^respec:/;

    $href =~ s/^respec://;
    my $resDir;
    if ($href =~ m/\.css$/) {
        $resDir = 'CSS';
    }
    elsif ($href =~ m/\.xsl(?:t)?$/) {
        $resDir = 'XSLT';
    }
    elsif ($href =~ m/\.(png|jpg|jpeg|gif)$/) {
        $resDir = 'Pics';
    }
    elsif ($href =~ m/\.tpl$/) {
        $resDir = 'Templates';
    }
    else {
        die "Unsupported resource format for respec locator '$href'";
    }
    my $path = $class->respecDir;
    $path->pushDirs('ReSpec', $resDir);
    $path->file($href);
    return $path->path;
}

sub getFileContent {
    my $file = shift;
    open my $FH, '<:utf8', $file or die "Can't open file '$file': $!\n";
    my $ret = do {local $/ = undef; <$FH> };
    close $FH;
    return $ret;
}

1;
__END__

=head1 NAME

ReSpec::FS - File-system facilities

=head1 SYNOPSIS

  ...

=head1 DESCRIPTION

This is a collection of facilities used to access the file-system. We of course
use File::Spec under the hood, but some parts can clearly be abstracted further.

=head1 METHODS

=over 4

=item new $path, $noFile

Constructor. Both args are optional. The second if true indicates that the last
component of a path is a directory, not a file.

=item parseFilePath $path

Constructor, mnemonic for calling new with $noFile set to false.

=item parseDirPath $path

Constructor, mnemonic for calling new with $noFile set to true.

=item respecDir

Constructor, returns an object set up with the base dir of ReSpec. Useful when
you need to get to ReSpec resources, though respecToFile is more likely what you
want unless you're seriously messing with internals.

=item clear

Resets an object to its blank state and returns it.

=item rel2abs $file, $base

Given a file and its base (defaults to current dir) returns the absolute path as
a string. This is just a wrapper around File::Spec.

=item path

Returns the object as a stringified path.

=item basePath

Same as path but without the file at the end.

=item file, dirs, volume

Accessors, they get/set their respective fields. Note that dirs is an array ref.

=item pushDirs @dirs

Adds directories to the path captured by the object. Each directory name
must be passed as a separate item.

=item respecToFile

Given a respec URL, returns the path to the file that corresponds to it.

=back


=head1 AUTHOR

Robin Berjon, E<lt>robin.berjon@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Robin Berjon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
