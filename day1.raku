sub find_calibration_value (Str $s --> Int){
    my @codepoints = $s.ords();
    my $c1 = Nil;
    my $c2 = Nil;
    my &isdigit = sub ($c) {return ($c >= 48 and $c < 58);}
    for @codepoints -> $c {
        if (isdigit $c) {
            $c1 = $c;
            last;
        }
    }
    for @codepoints.reverse() -> $c {
        if (isdigit $c) {
            $c2 = $c;
            last;
        }
    }
    # unless $c1 and $c2 die "";
    return ($c1-48)*10 + $c2-48;
}

sub find_cv2(Str $s) {
    constant %words = "zero" => 0, "one" => 1, "two" => 2, "three" => 3, "four" => 4,
                      "five" => 5, "six" => 6, "seven" => 7, "eight" => 8, "nine" =>9;
    constant $regex = /three|five|one|two|four|zero|eight|nine|six|seven/;
    my @s_chars = $s.split("", :skip-empty);
    my @ms = $s.match($regex, :exhaustive);
    for @ms -> $ms {
        @s_chars[$ms.from()] = %words{$ms.Str}.Str;
    }
    my $new_s = @s_chars.reduce: &infix:<~>;
    return find_calibration_value($new_s);
}

sub MAIN($name){
    my $fh = open :r, $name;
    my $sum1 = 0;
    my $sum2 = 0;
    for $fh.lines -> $line {
        $sum1 += find_calibration_value($line);
        $sum2 += find_cv2($line);
    }
    say $sum1;
    say $sum2;
}
