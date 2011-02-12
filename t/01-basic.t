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
    is $out, "1: (Foo)\n", 'OO interface works';
}

## 2. Test Filter/UnFilter routines.
{
    my $out;
    Filter \*STDOUT, sub {
        $out = sprintf "%d: %s\n", 1, "@_";
        ()
    };
    print "Foo";
    UnFilter \*STDOUT;
    is $out, "1: Foo\n", 'Filtering a handle works';

    ## 3. Test that we're actually untie-d (we should be).
    ok !tied *STDOUT, 'calling UnFilter unties the handle';
}

## 4. Test tie interface.
{
    my $test_out = "tout";
    open my $fh, '>', $test_out or die "Can't open $test_out: $!";
    tie *STDOUT, 'Filter::Handle', $fh, sub {
        sprintf "%d: %s\n", 1, "@_";
    };
    print "Foo";
    untie *STDOUT;
    close $fh;
    open $fh, "$test_out" or die "Can't open $test_out: $!";
    is scalar <$fh>, "1: Foo\n", 'Tied interface works';
    close $fh;
    unlink $test_out or die "Can't unlink $test_out: $!";
}