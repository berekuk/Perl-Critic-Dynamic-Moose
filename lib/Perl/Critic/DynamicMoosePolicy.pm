package Perl::Critic::DynamicMoosePolicy;
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
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Perl::Critic::DynamicMoosePolicy

=head1 DESCRIPTION

This documentation is written for policy authors. You may instead want
L<Perl::Critic::Dynamic::Moose>.

This class is a base class for dynamic Moose policies. This class facilitates
critiquing metaclasses (instead of the usual PPI documents). For example,
L<Perl::Critic::Policy::DynamicMoose::ProhibitPublicBuilders> critiques
metaclasses by checking whether any of their attributes' builders do not start
with an underscore. Due to the very dynamic nature of Moose and
metaprogramming, such policies will be much more effective than static analysis
at critiquing classes.

=head1 PUBLIC METHODS

=over 4

=item C<applies_to_metaclass>

Returns a list of metaclass names that this policy can critique. By default,
the list is L<Class::MOP::Class>. You may use the augment modifier to add
other kinds of metaclasses, such as L<Moose::Meta::Role> without having to
repeat the L<Class::MOP::Class>:

    augment applies_to_metaclass => sub { 'Moose::Meta::Role' };

Note that only the top-level metaclass is given to you. If you want to critique
only attributes, then you must do the Visiting yourself.

=item C<applies_to_themes>

Returns a list of themes for Perl::Critic so that users can run a particular
subset of themes on their code. By default, the list contains C<moose> and
C<dynamic>. You should use the augment modifier to add more themes instead
of overriding the method:

    augment themes => sub { 'role' };

=item C<violation>

This extends the regular L<Perl::Critic::Policy/violation> method by providing
a (rather useless) default value for the C<element> parameter. For nearly all
cases, there's no easy way to find where a metaclass violation occurred. You
may still pass such an element if you have one. However, since you probably do
not, you should be exact in your violation's description.

=item C<violates_metaclass>

This method is required to be overridden by subclasses. It takes a metaclass
object and the L<Perl::Critic::Document> representing the entire compilation
unit. It is expected to return a list of L<Perl::Critic::Violation> objects.

=over

=head1 POLICIES

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

