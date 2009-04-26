package Perl::Critic::Policy::Dynamic::Moose;
use Moose;
extends 'Perl::Critic::DynamicPolicy';

sub violates_dynamic {
    my $self = shift;
    my $doc  = shift;


}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

