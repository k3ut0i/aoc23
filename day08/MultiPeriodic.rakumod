class MultiPeriodic{
    has @.initial-overhead;
    has $!overhead-len = @!initial-overhead.elems;
    has @.periodic;
    has $!periodic-len = @!periodic.elems;
    has Bool $!in-init = True;
    has Int $!pos = 0;
    method new(@io, @p){
        self.bless(initial-overhead => @io, periodic => @p);
    }
    method next(){
        if ($!in-init) {
            given ($!pos cmp $!overhead-len) {
                when Less { $!pos++; return @!initial-overhead[$!pos-1]; }
                when Same {
                    $!in-init = False;
                    $!pos = 1 mod $!periodic-len; # mod need when singly perodic
                    return @!periodic[0];
                }
                when More { die "This shouldn't have happened: $!pos"; }
            }
        } else {
            my $ret-val = @!periodic[$!pos];
            $!pos = ($!pos + 1) mod $!periodic-len;
            return $ret-val;
        }

    }
}
