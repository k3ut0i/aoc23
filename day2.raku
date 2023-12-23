grammar Game {
    token TOP { 'Game' \s+ <game_num>  ':' \s+ <game_list> }
    token game_num { \d+ }
    token game_list { <game> [';' \s+ <game>]* }
    token game { <ball_set> [',' \s+ <ball_set>]* }
    token ball_set { <ball_num> \s+ <ball_color> }
    token ball_num { \d+ }
    token ball_color { 'blue' | 'green' | 'red' }
}

constant %max = 'red' => 12, 'green' => 13, 'blue' => 14;

sub possible ($g --> Bool) {
    for $g.hash{'game_list'}.hash{'game'} -> $gs {
        for $gs.hash{'ball_set'} -> $bs {
            if (%max{$bs.hash{'ball_color'}} < $bs.hash{'ball_num'}) {
                return False;
            }
        }
    }
    return True;
}

sub part2($g --> Int) {
    my %balls_max = "red" => 0, "blue" => 0, "green" => 0;
    for $g.hash{'game_list'}.hash{'game'} -> $gs {
        for $gs.hash{'ball_set'} -> $bs {
            if (%balls_max{$bs.hash{'ball_color'}} < $bs.hash{'ball_num'}) {
                %balls_max{$bs.hash{'ball_color'}} = $bs.hash{'ball_num'};
            }
        }
    }
    return %balls_max.values.reduce: &infix:<*>;
}

sub MAIN($name){
    my $fh = open :r, $name;
    my $id_sum = 0;
    my $power_sum = 0;
    for $fh.lines -> $line {
        my $g = Game.parse($line);
        if (possible($g)) {
            $id_sum += $g.hash{'game_num'};
        }
        $power_sum += part2($g);
    }
    say $id_sum;
    say $power_sum;
}
