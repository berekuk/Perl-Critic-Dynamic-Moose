package Perl::Critic::Policy::DynamicMoose::ClassOverridesRole;
use Moose;
extends 'Perl::Critic::Policy::DynamicMoose';

use Perl::Critic::Utils ':severities';

Readonly::Scalar my $EXPL => q{};
sub default_severity { $SEVERITY_MEDIUM }

sub violates_metaclass {
    my $self = shift;
    my $meta = shift;

    return;
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

