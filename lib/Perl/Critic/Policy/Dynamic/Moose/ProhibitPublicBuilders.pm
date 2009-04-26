package Perl::Critic::Policy::Dynamic::Moose::ProhibitPublicBuilders;
use Moose;
extends 'Perl::Critic::Policy::Dynamic::Moose';

Readonly::Scalar my $DESC = q{Builder method name without a leading underscore};
Readonly::Scalar my $EXPL = q{Prefix builder method names with an underscore};

sub violates_metaclass {
    my $self = shift;
    my $meta = shift;

    my @violations;

    my $attributes = $meta->get_attribute_map;
    for my $name (keys %$attributes) {
        my $attribute = $attributes->{$name};

        next if !$attribute->has_builder;

        if ($attribute->builder =~ /^_/) {
            push @violations, $self->violation($DESC, $EXPL);
        }
    }

    return @violations;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

