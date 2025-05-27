package Test2::Util::DistFiles;

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

our @EXPORT_OK = qw( manifest_files is_perl_file );

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

1;
