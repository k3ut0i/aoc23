class RangeMap {
    has Int $.des;
    has Int $.src;
    has Int $.len;

    method is-in(Int $x --> Bool) { return ($!src <= $x < $!src + $!len); }

    method maps(Int $x --> Int) { return $!des + $x - $!src; }

    method src-max ( --> Int ) { return $!src + $!len - 1; }

    method des-max ( --> Int ) { return $!des + $!len - 1; }

    method r-maps(Range:D $interval --> Range:_) {
        my $is = intersection($interval, Range.new($!src, self.src-max));
        if $is.defined {
            return Range.new(self.maps($is.min), self.maps($is.max));
        } else {
            return Range;
        }
    }

    method raku() {
        # src->des(len)
        return $!src ~ '->' ~ $!des ~ '(' ~ $!len ~ ')';
    }
}

sub intersection(Range:D $r1, Range:D $r2 --> Range:_){
    my Bool $r1small = $r1.min <= $r2.min;
    my $a = $r1small ?? $r1 !! $r2;
    my $b = $r1small ?? $r2 !! $r1;
    if ($a.max < $b.min) {
        return Range;
    } elsif ($a.max >= $b.max) {
        return $b;
    } else {
        return Range.new($b.min, $a.max);
    }
}

sub defined-map(@seq, &block){
    my @result;
    for @seq -> $s {
        my $r = block($s);
        if $r.defined { @result.push($r); }
    }
    return @result;
}

class AlmanacMap {
    has @.ranges;
    has Str $.from;
    has Str $.to;

    method new(:$from, :$to, :$ranges) {
        return self.bless(from => $from, to => $to,
                          ranges => $ranges.sort: *.src).expand-ids();
    }

    method expand-ids() {
        my @new-ranges;
        my $i = 0;
        for @!ranges -> $rm {
            given ($rm.src cmp $i) {
                when Less {
                    die "This shouldn't be possible $rm.src, $i";
                }
                when Same { @new-ranges.push($rm); $i = $rm.src + $rm.len; }
                when More {
                    @new-ranges.push(RangeMap.new(src => $i, des => $i,
                                                  len => $rm.src - $i));
                    @new-ranges.push($rm);
                    $i = $rm.src + $rm.len;
                }
            }
        }
        @!ranges = @new-ranges;
        return self;
    }

    method find_des_of(RangeMap:D $interval) {
        my @applicable-ranges;
        for @!ranges -> $rm { # XXX: this can get efficient by binary search
            my Bool $contains = ($interval.min <= $rm.src and $rm.src-max() <= $interval.max);
            my Bool $crosses = ($rm.src <= $interval.min <= $rm.src-max() or $rm.src <= $interval.max <= $rm.src-max());
            if  $contains or $crosses {
                @applicable-ranges.push($rm);
            }
        }
        return defined-map(@applicable-ranges, *.r-maps($interval));
    }

    method dump_map($fh){
        $fh.say("$($!from)\t$($!to)");
        for @!ranges -> $rm {
            $fh.say("$($rm.src)\t$($rm.des)\n$($rm.src-max)\t$($rm.des-max)");
        }
        $fh.print-nl;
    }
}

class Almanac {
    has @.seeds;
    has %.src-maps;

    method dump() {
        constant $tmp_dir_name = "tmp-day05";
        unless ($tmp_dir_name.IO.e) { mkdir $tmp_dir_name; }
        for %!src-maps.values -> $m {
            my $fh = open :w, "$tmp_dir_name/$($m.from)-$($m.to).data";
            $m.dump_map($fh);
            close $fh;
        }
    }
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
    $g.dump();
}
