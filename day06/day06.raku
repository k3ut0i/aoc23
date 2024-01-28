sub num-ways(Int $t, Int $d --> Int) {
    my $det = sqrt($t*$t/4 - $d - 1); # adding 1 to distance, we need to exceed it
    my $t1 = ceiling($t/2-$det);
    my $t2 = floor($t/2+$det);
    return $t2 - $t1 + 1;
}

sub MAIN($name){
    my $fh = open :r, $name;
    my ($time_line, $dist_line) = $fh.lines;
    my @times = $time_line.split(/\s+/)[1..*].map(*.Int);
    my @dists = $dist_line.split(/\s+/)[1..*].map(*.Int);

    my @ways = zip @times, @dists, :with(&num-ways);
    say @ways.reduce: &infix:<*>; # part1

    my $time-str = @times.reduce: &infix:<~>;
    my $dist-str = @dists.reduce: &infix:<~>;
    say num-ways($time-str.Int, $dist-str.Int);
}
