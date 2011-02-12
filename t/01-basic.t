use Test::More tests => 4;

use Filter::Handle qw( subs );

## 1. Test OO interface and printf method.
{
    my $out;
    my $f = Filter::Handle->new(\*STDOUT, sub {
        $out = sprintf "%d: %s\n", 1, "@_";
        ()
    });
    $f->printf("(%s)", "Foo");
    is $out, "1: (Foo)\n";
}

## 2. Test Filter/UnFilter routines.
my $out;
Filter \*STDOUT, sub {
    $out = sprintf "%d: %s\n", 1, "@_";
    ()
};
print "Foo";
UnFilter \*STDOUT;
is $out, "1: (Foo)\n";

## 3. Test that we're actually untie-d (we should be).
ok !tied *STDOUT;

## 4. Test tie interface.
local *FH;
my $test_out = "tout";
open FH, ">$test_out" or die "Can't open $test_out: $!";
tie *STDOUT, 'Filter::Handle', \*FH, sub {
    sprintf "%d: %s\n", 1, "@_";
};
print "Foo";
untie *STDOUT;
open FH, "$test_out" or die "Can't open $test_out: $!";
is scalar <FH>, "1: Foo\n";
close FH;
unlink $test_out or die "Can't unlink $test_out: $!";