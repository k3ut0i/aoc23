# -*- mode: raku -*-
use Test;
use MultiPeriodic;

my $m = MultiPeriodic.new([1, 2, 3], [1, 7, 9]);
is(gather for 1..8 { take $m.next; }, [1, 2, 3, 1, 7, 9, 1, 7]);
done-testing();
