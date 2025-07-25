package Test2::Util::DistFiles;

# ABSTRACT: Gather a list of files in a distribution

use v5.14;
use warnings;

use Carp                    qw( croak );
use Cwd::Guard              qw( cwd_guard );
use Exporter 5.57           qw( import );
use ExtUtils::Manifest 1.68 qw( manifind maniread maniskip );
use File::Basename          qw( basename );
use File::Spec;
use IO::File;
use Ref::Util qw( is_plain_hashref );

# RECOMMEND PREREQ: Ref::Util::XS

our @EXPORT_OK = qw( manifest_files is_perl_file );

our $VERSION = 'v0.2.2';

=head1 SYNOPSIS

    use Test2::V0;
    use Test2::Util::DistFiles qw( manifest_files is_perl_file );

    my @perl = manifest_files( \&is_perl_file);

=head1 DESCRIPTION

This is a utility module that gathers lists files in a distribution, intended for author, or release tests for
developers.

=export manifest_files

    my @files = manifest_files(); # use default filter

    my @files = manifest_files( \%options, \&filter );

    my @perl  = manifest_files( \&is_perl_file );

This returns a list of files from the F<MANIFEST>, filtered by an optional function.

If there is no manifest, then it will use L<ExtUtils::Manifest> to build a list of files that would be added to the
manifest.

The following options are supported:

=for stopwords dir

=over

=item dir

Search for files in this directory.

=item use_default

Use the default filter to ignore local lib files, build files, version control files and temporary files.

This is true by default.

=back

=cut

sub manifest_files {

    my $options = {};
    $options = shift if is_plain_hashref( $_[0] );

    state $nop = sub { 1 };

    my $filter = shift || $nop;

    my $guard;
    if ( my $dir = $options->{dir} ) {
        $guard = cwd_guard($dir) or croak "Cannot chdir to ${dir}: $Cwd::Guard::Error";
    }

    $options->{use_default} //= 1;

    my $default = $options->{use_default}
      ? sub {
        my ($file) = @_;
        my $name = basename($file);
        return
          if $file =~ m{^\.\w+/}                  # .git, .svn, .build, .mite ...
          || $file =~ m{^blib/}                   #
          || $file =~ m{^local/}                  # Carton
          || $name =~ m{^\.}                      #
          || $name =~ m{~$}
          || $name =~ m{^#.*#$}                   #
          || $name =~ m{\.(?:old|bak|backup)$}i
          || $file eq "Build";
        return 1;
      }
      : $nop;

    my $found;

    my $mfile = $ExtUtils::Manifest::MANIFEST;
    if ( -e $mfile ) {
        $found = maniread($mfile);
    }
    else {
        $found = manifind;
    }

    my $skip = maniskip;

    $guard = undef;

    my @files = grep { !$skip->($_) && $default->($_) && $filter->($_) } sort keys %{$found};
    return File::Spec->no_upwards(@files);
}

=export is_perl_file

This returns a list of Perl files in the distribution, excluding installation scaffolding like L<Module::Install> files
in F<inc>.

Note that it will include files like F<Makefile.PL> or F<Build.PL>.

=cut

sub is_perl_file {
    my ($file) = @_;
    my $name = basename($file);
    return   if $file =~ m{^(inc|local)/};
    return 1 if $name =~ /\.(?:PL|p[lm]|psgi|t)$/;
    return   if $name =~ /\.\w+$/ && $name !~ /\.bat$/;
    my $fh    = IO::File->new( $file, "r" ) or return;
    my $first = $fh->getline;
    return 1 if $first && ( $first =~ /^#!.*perl\b/ || $first =~ /--[*]-Perl-[*]--/ );
    return;
}

=head1 SEE ALSO

L<Test::XTFiles>

=head1 append:SOURCE

See F<CONTRIBUTING.md> for more information.

=head1 prepend:SUPPORT

Only the latest version of this module will be supported.

This module requires Perl v5.14 or later.  Future releases may only support Perl versions released in the last ten
years.

=head2 Reporting Bugs and Submitting Feature Requests

=head1 append:SUPPORT

If the bug you are reporting has security implications which make it inappropriate to send to a public issue tracker,
then see F<SECURITY.md> for instructions how to report security vulnerabilities.

=cut

1;
