class Graph{
    has %.adjacency-list;
    method new(@a){
        self.bless(adjacency-list => @a.map: {$_[0] => %(left => $_[1],
                                                         right => $_[2])});
    }
    method left(Str $n --> Str) { return %!adjacency-list{$n}<left>; }
    method right(Str $n --> Str) { return %!adjacency-list{$n}<right>; }
    method raku() { return %!adjacency-list.raku() }
    method dump-graphviz($fh){
        $fh.say('digraph {');
        my $indent = '  ';
        $fh.say($indent ~ 'node[shape=point];');
        $fh.say($indent ~ 'edge[arrowhead=none];');
        for %!adjacency-list.kv -> $k, $v {
            if ($k ~~ /.*A$/) {
                $fh.say($k ~ '[shape=diamond,color=green,style=filled];');
            } elsif ($k ~~ /.*Z$/) {
                $fh.say($k ~ '[shape=circle,color=red,style=filled];');
            }
            $fh.say($indent ~ $k ~ ' -> ' ~ $v<left> ~ ';');
            $fh.say($indent ~ $k ~ ' -> ' ~ $v<right> ~ ';');
        }
        $fh.say('}');
    }
}
