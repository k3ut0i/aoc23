use MyRange;
use RangeMap;
use Utils;

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

    method find_des_of(MyRange:D $interval) {
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
        $fh.say("$($!from)\t$($!to)\t$($!from)_des\t$($!to)_des");
        for @!ranges -> $rm {
            $fh.say("$($rm.src)\t$($rm.des)\t$($rm.src-max)\t$($rm.des-max)");
        }
        $fh.print-nl;
    }
}
