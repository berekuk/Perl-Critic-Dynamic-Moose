package Perl::Critic::Policy::DynamicMoose;
use Moose;
use MooseX::NonMoose;
extends 'Perl::Critic::DynamicPolicy';

has document => (
    is      => 'rw',
    isa     => 'PPI::Document',
    handles => [qw/ppi_document/],
);

sub applies_to { 'PPI::Document' }
sub applies_to_metaclass { 'Class::MOP::Class', inner() }
sub default_themes { qw(moose dynamic), inner() }

around violation => sub {
    my $orig    = shift;
    my $self    = shift;
    my $desc    = shift;
    my $expl    = shift;
    my $element = shift;

    if (!$element) {
        my $doc = $self->ppi_document;

        # Without this hack, Storable complains of being unable to reconstruct
        # overloading for an unknown package (perhaps PPI::Document?). For some
        # reason it works for PPI::Element. Anyway, this should hopefully be
        # replaced with a more useful location, something like
        # ( class:MyClass / attr:foo / builder:build_foo )
        $element = $doc->find('PPI::Element')->[0];
    }

    return $self->$orig($desc, $expl, $element, @_);
};

sub violates_dynamic {
    my $self = shift;
    my $doc  = shift;

    $self->document($doc);

    my $old_packages = $self->_find_packages;
    $self->_compile_document;
    my @new_packages = $self->_new_packages($old_packages);

    my @violations;
    for my $package (@new_packages) {
        my $meta = Class::MOP::class_of($package)
            or next;

        grep { $meta->isa($_) } $self->applies_to_metaclass
            or next;

        push @violations, $self->violates_metaclass($meta, $doc);
    }

    return @violations;
}

sub violates_metaclass { die "Your policy (" . blessed($_[0]) . ") needs to implement violates_metaclass" }

sub _compile_document {
    my $self = shift;
    my $doc = $self->document;

    my $source_code = $doc->content;

    eval $source_code;

    die "Unable to execute " . $doc->filename . ": $@" if $@;
}

sub _find_packages {
    my $self = shift;
    return [ Class::MOP::get_all_metaclass_names ];
}

sub _new_packages {
    my $self = shift;
    my $old  = shift;
    my @new;
    my %seen;

    $seen{$_} = 1 for @$old;

    for (@{ $self->_find_packages }) {
        push @new, $_ if !$seen{$_}++;
    }

    return @new;
}

no Moose;

1;

__END__

=head1 NAME

Perl::Critic::Policy::DynamicMoose

=head1 DESCRIPTION

The included policies are:

=over 4

=item L<Perl::Critic::Policy::DynamicMoose::ProhibitPublicBuilders>

Prohibit public builder methods for attributes. [Severity: 3]

=back

=head1 WARNING

B<VERY IMPORTANT:> Most L<Perl::Critic> Policies (including all the ones that
ship with Perl::Critic> use pure static analysis -- they never compile nor
execute any of the code that they analyze.  However, this policy is very
different.  It actually attempts to compile your code and then compares the
subroutines mentioned in your code to those found in the symbol table.
Therefore you should B<not> use this Policy on any code that you do not trust,
or may have undesirable side-effects at compile-time (such as connecting to the
network or mutating files).

For this Policy to work, all the modules included in your code must be
installed locally, and must compile without error.

=head1 AUTHOR

Shawn M Moore, C<sartak@bestpractical.com>

=cut

