package Test2::Util::DistFiles;

# ABSTRACT: gather files in a distribution

use v5.14;
use warnings;

use Carp                    qw( croak );
use Cwd                     qw( cwd chdir );
use Exporter 5.57           qw( import );
use ExtUtils::Manifest 1.68 qw( manifind maniread maniskip );
use File::Basename          qw( basename );
use File::Spec;
use IO::File;
use Ref::Util qw( is_plain_hashref );

# RECOMMEND PREREQ: Ref::Util::XS

our @EXPORT_OK = qw( manifest_files is_perl_file );

our $VERSION = 'v0.1.0';

=head1 SYNOPSIS

    use Test2::V0;
    use Test2::Util::DistFiles qw( manifest_files is_perl_file );

    my @perl = manifest_files( \&is_perl_file);

=head1 DESCRIPTION

This is a utility module that gathers lists files in a distribution, intended for author, or release tests for
developers.

=export manifest_files

    my @files = manifest_files();

    my @perl  = manifest_files( \&is_perl_file );

This returns a list of files from the F<MANIFEST>, filtered by an optional function.

If there is no manifest, then it will use L<ExtUtils::Manifest> to build a list of files that would be added to the
manifest.

=cut

sub manifest_files {

    my $options = {};
    $options = shift if is_plain_hashref( $_[0] );

    my $filter = shift;

    my $cwd;
    if ( my $dir = $options->{dir} ) {
        $cwd = cwd();
        chdir($dir) or croak "Cannot chdir to ${dir}";
    }

    my $default = sub {
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
    };

    $filter //= $default;

    my $found;

    my $mfile = $ExtUtils::Manifest::MANIFEST;
    if ( -e $mfile ) {
        $found = maniread($mfile);
    }
    else {
        $found = manifind;
    }

    my $skip = maniskip;

    chdir($cwd) if defined $cwd;

    my @files = grep { !$skip->($_) && $filter->($_) } sort keys %{$found};
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
    return   if $file =~ m{^inc/};                   # Module::Install
    return 1 if $name =~ /\.(?:PL|p[lm]|psgi|t)$/;
    return   if $name =~ /\.\w+$/ && $name !~ /\.bat$/;
    my $fh    = IO::File->new( $file, "r" ) or return;
    my $first = $fh->getline;
    return 1 if $first && ( $first =~ /^#!.*perl\b/ || $first =~ /--[*]-Perl-[*]--/ );
    return;
}

=head1 SEE ALSO

L<Test::XTFiles>

=cut

1;
