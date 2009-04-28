#!perl

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/branches/jeff/Perl-Critic-Dynamic/lib/Perl/Critic/Policy/Dynamic/ValidateAgainstSymbolTable.pm $
#     $Date: 2007-06-07 05:40:51 -0700 (Thu, 07 Jun 2007) $
#   $Author: thaljef $
# $Revision: 1617 $
##############################################################################

use strict;
use warnings;
use Test::More;
use English qw(-no_match_vars);

# common P::C testing tools
use Perl::Critic::TestUtils qw(subtests_in_tree pcritique);
Perl::Critic::TestUtils::block_perlcriticrc();

#-----------------------------------------------------------------------------

my $subtests = subtests_in_tree( 't' );

# Check for cmdline limit on policies.  Example:
#   perl -Ilib t/20_policies.t BuiltinFunctions::ProhibitLvalueSubstr
if (@ARGV) {
    my @policies = keys %{$subtests};
    # This is inefficient, but who cares...
    for my $p (@policies) {
        if (0 == grep {$_ eq $p} @ARGV) {
            delete $subtests->{$p};
        }
    }
}

#-----------------------------------------------------------------------------

# count how many tests there will be
my $nsubtests = 0;
for my $s (values %$subtests) {
    $nsubtests += @$s; # one [pf]critique() test per subtest
}
my $npolicies = scalar keys %$subtests; # one can() test per policy

plan tests => $nsubtests + $npolicies;

#-----------------------------------------------------------------------------

for my $policy ( sort keys %$subtests ) {

    can_ok( "Perl::Critic::Policy::$policy", 'violates' );

    for my $subtest ( @{$subtests->{$policy}} ) {

        local $TODO = $subtest->{TODO}; # Is NOT a TODO if it's not set
        my ($line, $test_name) = ($subtest->{lineno}, $subtest->{name});
        my $desc = join(' - ', $policy, "line $line", $test_name);

        my $number_of_violations =
          eval { pcritique($policy, \$subtest->{code}, $subtest->{parms}) };

        if ($subtest->{error}) {
            if ( 'Regexp' eq ref $subtest->{error} ) {
                like($EVAL_ERROR, $subtest->{error}, $desc);
            }
            else {
                ok($EVAL_ERROR, $desc);
            }
        }
        else {
            #die $EVAL_ERROR if $EVAL_ERROR;
            is($number_of_violations, $subtest->{failures}, $desc);
        }
    }
}

##############################################################################
# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 expandtab ft=perl:

