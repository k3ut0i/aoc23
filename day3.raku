sub point_neighbours($x, $y, $xmin, $xmax, $ymin, $ymax){
    my @choices = ([$x-1, $y-1], [$x-1, $y], [$x-1, $y+1],
                   [$x, $y-1], [$x, $y+1],
                   [$x+1, $y-1], [$x+1, $y], [$x+1, $y+1]);
    my @result;
    for @choices -> $p {
        if ($p[0] < $xmin or $p[0] > $xmax or $p[1] < $ymin or $p[1] > $ymax) {
            next;
        } else {
            @result.push($p);
        }
    }
    return @result;
}

sub number_neighbours($line_no, $c1, $c2, $xmin, $xmax, $ymin, $ymax){
    my @ns;
    for ($c1 .. $c2) -> $y {
        @ns.push: point_neighbours($line_no, $y, $xmin, $xmax, $ymin, $ymax).Slip;
    }
    my @uniques = @ns.unique(:with({$^a[0] == $^b[0] and $^a[1] == $^b[1]}));
    return @uniques.grep: -> $p { not ($p[0] == $line_no and $c1 <= $p[1] <= $c2) }
}

my regex num_code { $<line_no>=(\d+)\:$<start>=(\d+)\-$<end>=(\d+) }

sub sum_of_part_numbers(%nums, %syms, $maxcols, $maxrows){
    my $sum = 0;
    for %nums.keys -> $num {
        my $m = $num ~~ &num_code;
        my $line_no = $m.hash{'line_no'};
        my $start = $m.hash{'start'};
        my $end = $m.hash{'end'};
        my @ns = number_neighbours($line_no, $start, $end, 0, $maxcols, 0, $maxrows);
        for @ns -> $n {
            my $pos = $n[0] ~ ',' ~ $n[1];
            if ( $pos (elem) %syms.keys) {
                $sum += %nums{$num};
            }
        }
    }
    return $sum;
}

sub point_on_num($point, $num_str){
    my $m = $num_str ~~ &num_code;
    my $line_no = $m.hash{'line_no'}.Int;
    my $start = $m.hash{'start'}.Int;
    my $end = $m.hash{'end'}.Int;
    return (($point[0] == $line_no) and ($start <= $point[1] <= $end));
}

sub sum_of_gear_ratios(%nums, %syms, $maxcols, $maxrows){
    my $sum = 0;
    for %syms.keys -> $sym_pos {
        if %syms{$sym_pos} eq '*' {
            my $m = $sym_pos ~~ /$<x>=(\d+)\,$<y>=(\d+)/;
            my @ns = point_neighbours($m.hash{'x'}.Int, $m.hash{'y'}.Int,
                                      0, $maxcols, 0, $maxrows);
            my @num_neighbours;
            for @ns -> $n {
                for %nums.keys -> $num_pos {
                    if point_on_num($n, $num_pos) {
                        @num_neighbours.push($num_pos);
                    }
                }
            }
            my @unique_nums = @num_neighbours.unique;
            if @unique_nums.elems == 2 {
                $sum += %nums{@unique_nums[0]} * %nums{@unique_nums[1]};
            }
        }
    }
    return $sum;
}

sub MAIN($name){
    my $fh = open :r, $name;
    my %nums;
    my %syms;
    my $line_no = 0;
    my @lines = $fh.lines;
    my $line_length = @lines[0].chars;
    for @lines -> $line {
        my @ms = $line.match(/$<num>=(\d+)/, :global);
        for @ms -> $m {
            %nums{$line_no.Str ~ ':' ~ $m.from.Str ~ '-' ~ ($m.to - 1).Str } =
                $m.hash{'num'}.Int;
        }
        my @symbol_matches = $line.match(/$<sym_char>=(<-[.0..9]>)/, :global);
        for @symbol_matches -> $sm {
            %syms{$line_no.Str ~ ',' ~ $sm.from.Str} = $sm.hash{'sym_char'}.Str;
        }
        $line_no++;
    }
    say sum_of_part_numbers(%nums, %syms, $line_length-1, $line_no-1);
    say sum_of_gear_ratios(%nums, %syms, $line_length-1, $line_no-1);
}
