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
