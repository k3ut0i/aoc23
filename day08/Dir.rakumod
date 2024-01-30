enum Dir (left => 0, right => 1);
constant %dir-map = ('L' => left, 'R' => right);

class Dirs {
    has @.data;
    has Int $.pos is rw;
    method new(Str $s) {
        self.bless(pos => 0, data => $s.comb.map: { %dir-map{$_} });
    }
    
    method next(){
        my $r = @.data[$!pos];
        $!pos = @.data[$!pos+1].defined ?? ($!pos + 1) !! 0;
        return $r;
    }
}
