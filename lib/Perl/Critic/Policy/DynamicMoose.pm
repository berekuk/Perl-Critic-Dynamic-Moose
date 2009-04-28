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

around violation => sub {
    my $orig    = shift;
    my $self    = shift;
    my $desc    = shift;
    my $expl    = shift;
    my $element = shift;

    if (!$element) {
        my $doc = $self->ppi_document;
        $element = $doc->find('PPI::Element')->[0];
    }

    return $self->$orig($desc, $expl, $element, @_);
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

    my $source_code = $doc->content;

    eval $source_code;

    die "Unable to execute " . $doc->filename . ": $@" if $@;
}

sub find_packages {
    my $self = shift;
    my $doc = $self->document;

    return map { $_->namespace }
           @{ $doc->find('PPI::Statement::Package') || [] };
}

no Moose;

1;

