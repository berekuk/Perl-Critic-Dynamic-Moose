package Perl::Critic::Policy::DynamicMoose::ClassOverridesRole;
use Moose;
extends 'Perl::Critic::DynamicMoosePolicy';

use Perl::Critic::Utils ':severities';

Readonly::Scalar my $EXPL => q{Explicitly exclude overriden methods};
sub default_severity { $SEVERITY_MEDIUM }

# Class::MOP::Class has no roles
sub applies_to_metaclass { 'Moose::Meta::Class' }

sub violates_metaclass {
    my $self  = shift;
    my $class = shift;

    my @violations;

    for my $application ($class->role_applications) {
        my $role = $application->role;
        for my $method ($role->get_method_list) {
            next if $application->is_method_excluded($method);
            next if $application->is_method_aliased($method);

            my $method_object = $class->get_method($method)
                or next;

            # no metadata, should check source role to make sure it's the
            # same as $role
            if ($method_object->isa('Moose::Meta::Role::Method')) {
                next if $method_object->original_package_name eq $role->name;
            }

            my $class_name = $class->name;
            my $role_name  = $role->name;

            my $desc = "Class '$class_name' method '$method' implicitly overrides the same method from role '$role_name'";
            push @violations, $self->violation($desc, $EXPL);
        }
    }

    return @violations;
}

no Moose;

1;

__END__

=head1 NAME

Perl::Critic::Policy::DynamicMoose::ClassOverridesRole

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

