package Dist::Zilla::Plugin::ApacheTest;

# ABSTRACT: DEPRECATED ApacheTest Compatibility Module.

use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::ApacheTest';


__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 SYNOPSIS

B<DEPRECATED>.  Use L<@ApacheTest> instead.

=head1 DESCRIPTION

This plugin exists for compatibility reasons with previouis versions of this
module.  You whould switch to the L<@ApacheTest> bundle instead.  This module
simply uses the
L<MakeMaker::ApacheTest|Dist::Zilla::Plugin::MakeMaker::ApacheTest> plugin.

=head1 SEE ALSO

L<@ApacheTest|Dist::Zilla::PluginBundle::ApacheTest>

=cut
