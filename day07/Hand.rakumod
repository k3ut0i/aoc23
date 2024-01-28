enum HandType(high-card => 1, one-pair => 2, two-pair => 3, three-of => 4,
              full-house => 5, four-of => 6, five-of => 7);

sub find-type(Str $s --> HandType:D) is export {
    my %chars;
    for $s.comb -> $c {
        if %chars{$c} { %chars{$c}++; }
        else { %chars{$c} = 1; }
    }
    given %chars.values.sort {
        when List.new(5) { return HandType::five-of; }
        when (1, 4) { return four-of; }
        when (2, 3) { return full-house; }
        when (1, 1, 3) { return three-of; }
        when (1, 2, 2) { return two-pair; }
        when (1, 1, 1, 2) { return one-pair; }
        when (1, 1, 1, 1, 1) { return high-card; }
        default { die "unknown handtype for" ~ $s; }
    }
}
constant %bc = <A Z K Y Q X J W T U>;
class Hand {
    has Str $.str;
    has Str $.estr is rw;
    has HandType $.type is rw;
    method new(Str $s){
        my $es = $s.comb.map({ %bc{$_}.defined ?? %bc{$_} !! $_ }).reduce: &infix:<~>;
        return self.bless(str => $s, estr => $es, type => find-type($s));
    }
    method raku() { return $.str ~ $.type ~ $.estr; }
    method joker-upgrade(){
        my $j-count = $.str.comb.grep('J').elems;
        if $j-count > 0 {
            given $.type {
                when high-card { $.type = one-pair; }
                when one-pair { $.type = three-of; }
                when two-pair {
                    given $.str.comb.grep('J').elems {
                        when 1 { $.type = full-house; }
                        when 2 { $.type = four-of; }
                        default {
                            die self.raku ~ ": two-pair should not have " ~ $_ ~ " jokers";
                        }
                    }
                }
                when three-of { $.type = four-of; }
                default { $.type = five-of; } 
            }
            $.estr = $.estr.subst(/W/, '1', :g);
        }
    }
};
