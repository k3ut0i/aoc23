module Utils {
    sub defined-map(@seq, &block) is export {
        my @result;
        for @seq -> $s {
            my $r = block($s);
            if $r.defined { @result.push($r); }
        }
        return @result;
    }
}
