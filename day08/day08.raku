use Dir;
use Graph;

my regex Nr { $<node>=(\w+)\s*'='\s*'('\s*$<left>=(\w+)\s*','\s*$<right>=(\w+)')' };

sub parse-node(Str $s --> List) {
    my $m = $s ~~ &Nr;
    return ($m<node>.Str, $m<left>.Str, $m<right>.Str);
}

sub graph-next(Graph $g, Dir $dt, Str $current) {
    given $dt {
        when left { return $g.left($current); }
        when right { return $g.right($current); }
    }
}

sub steps-to(Graph $g, Dirs $d, Str $from, Str $to --> Int) {
    my $steps = 0;
    my $current = $from;
    until ($current eq $to) {
        $current = graph-next($g, $d.next, $current);
        $steps++;
    }
    return $steps;
}

sub ghost-steps(Graph $g, Dirs $d --> Int) {
    my @starts = $g.adjacency-list.keys.grep: { $^a ~~ /.*A$/};
    my $steps = 0;
    my @current is Array[Str] = @starts;
    until (@current.all ~~ /.*Z$/) {
        my $dt = $d.next;
        for @current -> $c is rw {
            $c = graph-next($g, $dt, $c);
        }
        $steps++;
    }
    return $steps;
}

sub find-structure(Graph $g, Dirs $d, Str $from --> List) {
    my %visited;
    
}

sub MAIN($filename){
    my $fh = open :r, $filename;
    my @lines = $fh.lines;
    my $dirs = Dirs(@lines[0]);
    my @nodelist = @lines[2..*].map: &parse-node;
    my $g = Graph(@nodelist);
    # say steps-to($g, $dirs, 'AAA', 'ZZZ');
    # say ghost-steps($g, $dirs);
    $g.dump-graphviz($*OUT);
}
