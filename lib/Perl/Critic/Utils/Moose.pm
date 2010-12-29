package Perl::Critic::Utils::Moose;
use strict;
use warnings;

# ABSTRACT: utils for Perl::Critic::DynamicMoosePolicy modules

use Sub::Exporter -setup => {
    exports => ['meta_type'],
};

my @types = (
    [ 'Moose::Meta::Role'              => 'role'            ],
    [ 'Moose::Meta::TypeCoercion'      => 'type coercion'   ],
    [ 'Moose::Meta::TypeConstraint'    => 'type constraint' ],
    [ 'Moose::Meta::Role::Application' => 'role application' ],

    [ 'Class::MOP::Method'             => 'method'          ],
    [ 'Class::MOP::Attribute'          => 'attribute'       ],
    [ 'Class::MOP::Class'              => 'class'           ],
    [ 'Class::MOP::Module'             => 'module'          ],
    [ 'Class::MOP::Package'            => 'package'         ],
);

=head1 FUNCTIONS

=over

=item C<meta_type>

Get string type description by Moose metaclass name.

=cut
sub meta_type {
    my $meta = shift;

    for (@types) {
        my ($class, $name) = @$_;
        return $name if $meta->isa($class);
    }

    return undef;
}

=back

=cut

1;

