use AlmanacFile;
sub find_des($src, $src-name, $almanac){
    my $am = $almanac.src-maps{$src-name};
    my $des-name = $am.to;
    for $am.ranges -> $r {
        if $r.is-in($src) {
            return ($r.maps($src), $des-name);
        }
    }
    return ($src, $des-name);
}

sub find_location($src, $almanac){
    my $des-name = "seed";
    my $des = $src;
    while $des-name ne "location" {
        ($des, $des-name) = find_des($des, $des-name, $almanac);
    }
    return ($des, $des-name);
}

sub MAIN($file){
    my $fh = open :r, $file;
    my $g = AlmanacFile.parse($fh.slurp(:close), actions => AF-actions.new).made;
    my $min_location = Inf;
    for $g.seeds -> $s {
        my $loc = find_location($s, $g)[0];
        if $min_location > $loc { $min_location = $loc; }
    }
    say $min_location;
    $g.dump();
}
