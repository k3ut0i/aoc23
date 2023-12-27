grammar Card {
    token TOP { Card\s+<card_num>\:\s+<winners>\s+\|\s+<onhand> }
    token card_num { \d+ }
    token winners { \d+ [\s+\d+]* }
    token onhand { \d+ [\s+\d+]* }
}

class Card-actions
{
    method TOP($/){
        make { winners => $<winners>.made,
               onhand => $<onhand>.made,
               card_num => $<card_num>.Int }
    }

    method winners($/) {
        make $/.split(' ', :skip-empty).map: { $^a.Int }
    }

    method onhand($/) {
        make $/.split(' ', :skip-empty).map: { $^a.Int }
    }
}

sub matching-numbers($card) {
    return ($card<winners>.Set (&) $card<onhand>.Set).elems;
}

sub count-points($matches){
    return $matches > 0 ?? 2 ** ($matches - 1) !! 0;
}

sub total-cards(%card-matches, $ncards){
    my %cards;
    for 1 .. $ncards -> $n { %cards{$n} = 1; }
    for 1 .. $ncards -> $n {
        my $points = %card-matches{$n};
        for $n+1 .. $n+$points -> $m {
            %cards{$m} += %cards{$n};
        }
    }
    return %cards.values.reduce: &infix:<+>;
}

sub MAIN($file){
    my $fh = open :r, $file;
    my @lines = $fh.lines(:chomp);
    my $sum = 0;
    my %card-matches;
    my $ncards = 0;
    for @lines -> $line {
        my $c = Card.parse($line, actions => Card-actions.new).made;
        my $nmatches = matching-numbers($c) ;
        %card-matches{$c<card_num>} = $nmatches;
        $sum += count-points($nmatches);
        $ncards++;
    }
    say $sum;
    say total-cards(%card-matches, $ncards);
}
