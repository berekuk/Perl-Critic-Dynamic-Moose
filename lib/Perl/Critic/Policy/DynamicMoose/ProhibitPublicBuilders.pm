package Perl::Critic::Policy::DynamicMoose::ProhibitPublicBuilders;
use Moose;
extends 'Perl::Critic::Policy::DynamicMoose';

use Perl::Critic::Utils ':severities';
use Perl::Critic::Utils::Moose 'meta_type';

Readonly::Scalar my $EXPL => q{Prefix builder method names with an underscore};
sub default_severity { $SEVERITY_MEDIUM }

augment applies_to_metaclass => sub { 'Moose::Meta::Role' };

sub violates_metaclass {
    my $self = shift;
    my $meta = shift;

    my $classname = $meta->name;

    my @violations;

    my $attributes = $meta->get_attribute_map;
    for my $name (keys %$attributes) {
        my $attribute = $attributes->{$name};
        my $builder;

        if (blessed($attribute)) {
            next if !$attribute->has_builder;
            $builder = $attribute->builder;
        }
        else {
            # Roles suck :(
            next if !defined($attribute->{builder});
            $builder = $attribute->{builder};
        }

        if ($builder !~ /^_/) {
            my $type = meta_type($meta);
            my $desc = "Builder method '$builder' of attribute '$attribute' of $type '$classname' is public";
            push @violations, $self->violation($desc, $EXPL);
        }
    }

    return @violations;
}

no Moose;

1;

__END__

=head1 NAME

Perl::Critic::Policy::DynamicMoose::ProhibitPublicBuilders

=head1 DESCRIPTION

An attribute's L<Moose/builder> method is used to provide a default value
for that attribute. Such methods are rarely intended for external use, and
should not be considered part of that class's public API. Thus we recommend
that your attribute builder methods' names are prefixed with an underscore
to mark them private.

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

=cut

