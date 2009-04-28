package Perl::Critic::Policy::DynamicMoose::RequireMethodModifiers;
use Moose;
extends 'Perl::Critic::Policy::DynamicMoose';

use Perl::Critic::Utils ':severities';
use Perl::Critic::Utils::Moose 'meta_type';

Readonly::Scalar my $EXPL => q{Method modifiers make it clear that you're overriding methods.};
sub default_severity { $SEVERITY_LOW }

sub violates_metaclass {
    my $self = shift;
    my $meta = shift;

    my @violations;

    my $map = $meta->get_method_map;

    for my $name (keys %$map) {
        my $method = $map->{$name};

        # Modifiers are always fine.
        next if $method->isa('Class::MOP::Method::Wrapped')
             || $method->isa('Moose::Meta::Method::Overridden')
             || $method->isa('Moose::Meta::Method::Augmented');

        # Generated methods
        next if $method->isa('Class::MOP::Method::Generated');

        # XXX: this freaking sucks
        next if $name eq 'meta' || $name eq 'BUILD' || $name eq 'DEMOLISH';

        my $next = $meta->find_next_method_by_name($name);

        # Adding new methods is always fine.
        next if !$next;

        push @violations, $self->violation("The '$name' method of class " . $meta->name . " does not use a method modifier to override its superclass implementation.", $EXPL);
    }

    return @violations;
}

no Moose;

1;

__END__

=head1 NAME

Perl::Critic::Policy::DynamicMoose::RequireMethodModifiers

=head1 DESCRIPTION


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

