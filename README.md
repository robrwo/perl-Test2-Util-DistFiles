# NAME

Test2::Util::DistFiles - Gather a list of files in a distribution

# SYNOPSIS

```perl
use Test2::V0;
use Test2::Util::DistFiles qw( manifest_files is_perl_file );

my @perl = manifest_files( \&is_perl_file);
```

# DESCRIPTION

This is a utility module that gathers lists files in a distribution, intended for author, or release tests for
developers.

# RECENT CHANGES

Changes for version v0.2.2 (2025-08-01)

- Documentation
    - README is generated using Dist::Zilla::Plugin::UsefulReadme.
- Toolchain
    - Improve Dist::Zilla configuration.

See the `Changes` file for more details.

# REQUIREMENTS

This module lists the following modules as runtime dependencies:

- [Carp](https://metacpan.org/pod/Carp)
- [Cwd::Guard](https://metacpan.org/pod/Cwd%3A%3AGuard)
- [Exporter](https://metacpan.org/pod/Exporter) version 5.57 or later
- [ExtUtils::Manifest](https://metacpan.org/pod/ExtUtils%3A%3AManifest) version 1.68 or later
- [File::Basename](https://metacpan.org/pod/File%3A%3ABasename)
- [File::Spec](https://metacpan.org/pod/File%3A%3ASpec)
- [IO::File](https://metacpan.org/pod/IO%3A%3AFile)
- [Ref::Util](https://metacpan.org/pod/Ref%3A%3AUtil)
- [perl](https://metacpan.org/pod/perl) version v5.14.0 or later
- [warnings](https://metacpan.org/pod/warnings)

See the `cpanfile` file for the full list of prerequisites.

# INSTALLATION

The latest version of this module (along with any dependencies) can be installed from [CPAN](https://www.cpan.org) with the `cpan` tool that is included with Perl:

```
cpan Test2::Util::DistFiles
```

You can also extract the distribution archive and install this module (along with any dependencies):

```
cpan .
```

You can also install this module manually using the following commands:

```
perl Makefile.PL
make
make test
make install
```

If you are working with the source repository, then it may not have a `Makefile.PL` file.  But you can use the [Dist::Zilla](https://dzil.org/) tool in anger to build and install this module:

```
dzil build
dzil test
dzil install --install-command="cpan ."
```

For more information, see the `INSTALL` file included with this distribution.

# SUPPORT

Only the latest version of this module will be supported.

This module requires Perl v5.14 or later.  Future releases may only support Perl versions released in the last ten
years.

## Reporting Bugs and Submitting Feature Requests

Please report any bugs or feature requests on the bugtracker website
[https://github.com/robrwo/perl-Test2-Util-DistFiles/issues](https://github.com/robrwo/perl-Test2-Util-DistFiles/issues)

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

If the bug you are reporting has security implications which make it inappropriate to send to a public issue tracker,
then see `SECURITY.md` for instructions how to report security vulnerabilities.

# SOURCE

The development version is on github at [https://github.com/robrwo/perl-Test2-Util-DistFiles](https://github.com/robrwo/perl-Test2-Util-DistFiles)
and may be cloned from [git://github.com/robrwo/perl-Test2-Util-DistFiles.git](git://github.com/robrwo/perl-Test2-Util-DistFiles.git)

See `CONTRIBUTING.md` for more information.

# AUTHOR

Robert Rothenberg <rrwo@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2025 by Robert Rothenberg.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# SEE ALSO

[Test::XTFiles](https://metacpan.org/pod/Test%3A%3AXTFiles)
