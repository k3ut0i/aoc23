use Hand;

sub MAIN($filename){
    my $fh = open :r, $filename;
    my %bids;
    my @hands;
    for $fh.lines -> $line {
        my ($hand-str, $bid-str) = $line.split(/\s+/);
        my $bid = $bid-str.Int;
        %bids{$hand-str} = $bid;
        @hands.push(Hand($hand-str));
    }
    #part1
    my @shands = @hands.sort({.type, .estr});
    my @scores = zip @shands, [1..Inf], :with({$^b * %bids{$^a.str}});
    say @scores.reduce: &infix:<+>;
    #part2
    @hands.map: *.joker-upgrade;
    my @shands1 = @hands.sort({.type, .estr});
    my @scores1 = zip @shands1, [1..Inf], :with({$^b * %bids{$^a.str}});
    say @scores1.reduce: &infix:<+>;
}
