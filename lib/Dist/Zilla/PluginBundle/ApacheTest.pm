package Dist::Zilla::PluginBundle::ApacheTest;

# ABSTRACT: Dist::Zilla Plugin Bundle That Configures Makefile.PL for Apache::Test

use Moose;

with 'Dist::Zilla::Role::PluginBundle::Easy';

sub configure {
    my $self = shift;

    my $args = $self->payload;

    $self->add_plugins(
        [
            'MakeMaker::ApacheTest' => {
                min_version => ($$args{min_version} || 0)
            }
        ],
        [
            'DynamicPrereqs' =>  {
                -raw => join('',
                    q[if ($mp_version == 2) { ],
                    q[    requires('mod_perl2', '1.999022'); ],
                    q[} ],
                    q[elsif ($mp_version == 1) { ],
                    q[    requires('mod_perl', '1.27'); ],
                    q[}]
                )
            }
        ]
    );
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=head1 SYNOPSIS

in dist.ini

 ; remove MakeMaker
 ;[MakeMaker]
 [@ApacheTest]
 min_version = 1.39

or, if you are using a bundle like L<@Classic|Dist::Zilla::PluginBundle::Classic>:

 [@Filter]
 bundle = @Classic
 remove = MakeMaker

 [@ApacheTest]

This is equivalent to the following:

 [MakeMaker::ApacheTest]
 [DynamicPrereqs]
 -raw = (code to require mod_perl if installed, otherwise mod_perl2)

=head1 DESCRIPTION

This plugin makes use of
L<MakeMaker::Awesome|Dist::Zilla::Plugin::MakeMaker::Awesome> to produce a
Makefile.PL with L<Apache::Test> hooks enabled.  If this plugin is loaded, you
should also load the L<Manifest|Dist::Zilla::Plugin::Manifest> plugin should
also be loaded, and the L<MakeMaker|Dist::Zilla::Plugin::MakeMaker> plugin.

=head1 CONFIGURATION OPTIONS

The following options are available in C<dist.ini> for this plugin:

=for :list
* min_version
The minimum version of Apache::Test that will be required in C<Makefile.PL>.
The default is C<0>.  You are B<strongly> encouraged to explicitly specify the
version of L<Apache::Test> that is required by your module instead of relying
on the default.

=head1 SEE ALSO

=for :list
* L<MakeMaker::Awesome|Dist::Zilla::Plugin::MakeMaker::Awesome>
* L<MakeMaker::ApacheTest|Dist::Zilla::Plugin::MakeMaker::ApacheTest>

=cut
