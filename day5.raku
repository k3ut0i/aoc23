class RangeMap {
    has Int $.des;
    has Int $.src;
    has Int $.len;

    method is-in(Int $x --> Bool) {
        return ($!src <= $x < $!src + $!len);
    }

    method maps(Int $x --> Int) {
        return $!des + $x - $!src;
    }
}

multi sub infix:<cmp>(RangeMap $a, RangeMap $b){
    return ($a.src cmp $b.src);
}

class AlmanacMap {
    has @.ranges;
    has Str $.from;
    has Str $.to;

}

class Almanac {
    has @.seeds;
    has %.src-maps;
}

grammar AlmanacFile {
    token TOP { seeds\:\s+<seed-data> \n\n <maps> .*}
    token seed-data { \d+[\s+\d+]* }
    token maps { <amap> [\n\n<amap>]* }
    token amap { <src-name> '-to-' <des-name> ' map'\:[\n<entry>]+ }
    token entry { <des>\s+<src>\s+<len> }
    token src-name { \w+ }
    token des-name { \w+ }
    token src { \d+ }
    token des { \d+ }
    token len { \d+ }
}

class AF-actions {
    method src($/) { make $/.Int }
    method des($/) { make $/.Int }
    method len($/) { make $/.Int }
    method entry($/) {
        make RangeMap.new(src => $<src>.made, des => $<des>.made,
                          len => $<len>.made)
    }
    method amap($/) {
        my @rs;
        for $<entry>.List -> $e {
            @rs.push($e.made);
        }
        make AlmanacMap.new(from => $<src-name>.Str, to => $<des-name>.Str,
                            ranges => @rs)}
    method maps($/) {
        my %sms;
        for $<amap> -> $m {
            my $mm = $m.made;
            %sms{$mm.from} = $mm;
        }
        make %sms;
    }

    method TOP($/) {
        my @seeds = $<seed-data>.split(' ', :skip-empty).map: *.Int;
        make Almanac.new(seeds => @seeds, src-maps => $<maps>.made);
    }
}

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
}
