package Dist::Zilla::Plugin::MakeMaker::ApacheTest;

# ABSTRACT: Dist::Zilla Plugin That Configures Makefile.PL for Apache::Test

use Moose;
use Moose::Autobox;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

# the minimum version of Apache::Test that is required.
has min_version => (
    is         => 'ro',
    isa        => 'Str',
    default    => sub { 0 });


around _build_header => sub {
    my ($orig, $self) = splice @_, 0, 2;

    my $header = $self->$orig(@_);

    return $header . <<'END';
# figure out if mod_perl v1 or v2 is installed.  DynamicPrereqs in the
# PluginBundle needs this to require the appropriate mod_perl module.
my $mp_version = mod_perl_version();

# configure Apache::Test
test_configure();
END
};

around register_prereqs => sub {
    my ($orig, $self) = splice @_, 0, 2;

    my $res = $self->$orig(@_);

    $self->zilla->register_prereqs(
        { phase => 'configure' },
        'Apache::Test' => $self->min_version
    );

    return $res;
};

# DZP::MakeMaker::Awesome does not have a hook for clean_files, so we have to
# munge the WriteMakefile args instead.
around _build_WriteMakefile_args => sub {
    my ($orig, $self) = splice @_, 0, 2;

    my $args = $self->$orig(@_);

    $args->{clean} ||= {};
    $args->{clean}{FILES} ||= [];

    push @{ $args->{clean}{FILES} }, 't/TEST';

    return $args;
};

around _build_footer => sub {
    my ($orig, $self) = splice @_, 0, 2;

    my $text = $self->$orig(@_);

    $text .= <<'END';
sub test_configure {
    require Apache::TestMM;

    # enable make test
    Apache::TestMM->import(qw(test clean));

    Apache::TestMM::filter_args();

    Apache::TestMM::generate_script('t/TEST');
}

sub mod_perl_version {
    # try MP2
    eval {
        require mod_perl2;
    };
    unless ($@) {
        return 2;
    }

    # try MP1
    eval {
        require mod_perl;
    };
    unless ($@) {
        if ($mod_perl::VERSION >= 1.99) {
            # mod_perl 2, prior to the mod_perl2 rename (1.99_21, AKA 2.0.0 RC5)
            die "mod_perl 2.0 RC5 or later is required\n";
        }

        return 1;
    }

    # assume mod_perl version 2 is wanted
    return 2;
}
END

    return $text;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__
=pod

=head1 SYNOPSIS

You problably don't want to use this plugin directly.  You probably want
the plugin bundle L<ApacheTest|Dist::Zilla::PluginBundle::ApacheTest> instead.

=head1 DESCRIPTION

This plugin will produce an L<ExtUtils::MakeMaker>-powered F<Makefile.PL> with
L<Apache::Test> hooks for the distribution.  If you use this plugin, you should
F<not> use the L<MakeMaker|Dist::Zilla::Plugin::MakeMaker> plugin.

This module extends
L<MakeMaker::Awesome|Dist::Zilla::Plugin::MakeMaker::Awesome> to fill in the
necessary part of the Makefile.PL to enable L<Apache::Test>.

=head1 CONFIGURATION OPTIONS

The following options are avaliable in F<dist.ini> for this plugin:

=for :list
* min_version
The minimum version of Apache::Test that will be required in C<Makefile.PL>.
The default is C<0>.  You are B<strongly> encouraged to explicitly specify the
version of L<Apache::Test> that is required by your module instead of relying
on the default.

=head1 SEE ALSO

=for :list
* L<MakeMaker::Awesome|Dist::Zilla::Plugin::MakeMaker::Awesome>

=cut
