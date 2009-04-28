package Perl::Critic::Policy::DynamicMoose::ProhibitPublicBuilders;
use Moose;
extends 'Perl::Critic::Policy::DynamicMoose';

use Perl::Critic::Util::Moose 'meta_type';

Readonly::Scalar my $EXPL => q{Prefix builder method names with an underscore};

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

