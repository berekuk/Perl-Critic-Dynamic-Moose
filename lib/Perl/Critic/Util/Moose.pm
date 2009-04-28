package Perl::Critic::Util::Moose;
use strict;
use warnings;
use base 'Exporter';

our @EXPORTS_OK = 'meta_type';

my @types = (
    [ 'Moose::Meta::Role'           => 'role'            ],
    [ 'Moose::Meta::TypeCoercion'   => 'type coercion'   ],
    [ 'Moose::Meta::TypeConstraint' => 'type constraint' ],

    [ 'Class::MOP::Method'          => 'method'          ],
    [ 'Class::MOP::Attribute'       => 'attribute'       ],
    [ 'Class::MOP::Class'           => 'class'           ],
    [ 'Class::MOP::Module'          => 'module'          ],
    [ 'Class::MOP::Package'         => 'package'         ],
);

sub meta_type {
    my $meta = shift;

    for (@types) {
        my ($class, $name) = @$_;
        return $name if $meta->isa($class);
    }

    return undef;
}

1;

