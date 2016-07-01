package Dist::Zilla::Plugin::ApacheTest;

# ABSTRACT: build a Makefile.PL that uses ExtUtils::MakeMaker with Apache::Test

use Moose;
use Moose::Autobox;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

# the minimum version of Apache::Test that is required.
has min_version => (
    is         => 'ro',
    isa        => 'Str',
    default    => sub { '1.39' });


around _build_header => sub {
    my ($orig, $self) = splice @_, 0, 2;

    my $header = $self->$orig(@_);

    return $header . <<'END';
# figure out if mod_perl v1 or v2 is installed.
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

in dist.ini:

 ; remove MakeMaker
 ;[MakeMaker]
 [ApacheTest]
 min_verision = 1.39

or if you use a bundle like C<@Classic>:

 [@Filter]
 bundle = @Classic
 remove = MakeMaker

 [ApacheTest]

=head1 DESCRIPTION

This plugin will produce an L<ExtUtils::MakeMaker>-powered F<Makefile.PL> with
Apache::Test hooks for the distribution.  If loaded, the
L<Manifest|Dist::Zilla::Plugin::Manifest> plugin should also be loaded, and the
L<MakeMaker|Dist::Zilla::Plugin::MakeMaker> plugin should not be loaded.

This module extends L<MakeMaker::Awesome|Dist::Zilla::Plugin::MakeMaker::Awesome> to fill in the necessary part of the Makefile.PL to enable L<Apache::Test>.

=head1 CONFIGURATION OPTIONS

The following options are avaliable in F<dist.ini> for this plugin:

=for :list
* min_version
The minimum version of Apache::Test that will be required in C<Makefile.PL>.
The default is C<1.39>, the most recent version of Apache::Test at the time of
this writing.  You are B<strongly> encouraged to explicitly specify the version
of L<Apache::Test> that is required by your module instead of relying on the
default.

=head1 SEE ALSO

=for :list
* L<MakeMaker::Awesome|Dist::Zilla::Plugin::MakeMaker::Awesome>

=cut
