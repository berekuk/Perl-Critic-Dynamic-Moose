package Perl::Critic::Policy::DynamicMoose::ProhibitPublicBuilders;
use Moose;
extends 'Perl::Critic::Policy::DynamicMoose';

Readonly::Scalar my $EXPL => q{Prefix builder method names with an underscore};

sub violates_metaclass {
    my $self = shift;
    my $meta = shift;

    my $classname = $meta->name;

    my @violations;

    my $attributes = $meta->get_attribute_map;
    for my $name (keys %$attributes) {
        my $attribute = $attributes->{$name};

        next if !$attribute->has_builder;

        my $builder = $attribute->builder;

        if ($builder !~ /^_/) {
            my $desc = "Builder method '$builder' of attribute '$attribute' of class '$classname' is public";
            push @violations, $self->violation($desc, $EXPL);
        }
    }

    return @violations;
}

no Moose;

1;

