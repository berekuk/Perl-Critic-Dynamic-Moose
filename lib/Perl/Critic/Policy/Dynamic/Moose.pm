package Perl::Critic::Policy::Dynamic::Moose;
use Moose;
use MooseX::NonMoose;
extends 'Perl::Critic::DynamicPolicy';

has document => (
    is  => 'rw',
    isa => 'PPI::Document',
);

sub applies_to { 'PPI::Document' }
sub applies_to_metaclass { 'Class::MOP::Class' }

around violation => sub {
    my $orig = shift;
    my $self = shift;
    my $desc = shift;
    my $expl = shift;
    my $doc  = shift || $self->document;

    return $self->$orig($desc, $expl, $doc, @_);
};

sub violates_dynamic {
    my $self = shift;
    my $doc  = shift;

    $self->document($doc);
    $self->compile_document;

    my @packages = $self->find_packages;

    my @violations;
    for my $package (@packages) {
        my $meta = Class::MOP::class_of($package)
            or next;

        grep { $meta->isa($_) } $self->applies_to_metaclass
            or next;

        push @violations, $self->violates_metaclass($meta, $doc);
    }

    return @violations;
}

sub compile_document {
    my $self = shift;
    my $doc = $self->document;

    eval "$doc";
    die "Unable to execute " . $doc->filename . ": $@";
}

sub find_packages {
    my $self = shift;
    my $doc = $self->document;

    return map { $_->namespace }
           @{ $doc->find('PPI::Statement::Package') || [] };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

