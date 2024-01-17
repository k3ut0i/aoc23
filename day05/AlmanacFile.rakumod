use Almanac;
use RangeMap;

grammar AlmanacFile {
    token TOP { seeds\:\s+<seed-data> \n\n <maps> .*}
    token seed-data { \d+[\s+\d+]* }
    token maps { <amap> [\n\n<amap>]* }
    token amap { <src-name> '-to-' <des-name> ' map'\:[\n<entry>]+ }
    token entry { <des>\s+<src>\s+<len> }
    token src-name { \w+ }
    token des-name { \w+ }
    token src { \d+ }
    token des { \d+ }
    token len { \d+ }
}

class AF-actions {
    method src($/) { make $/.Int }
    method des($/) { make $/.Int }
    method len($/) { make $/.Int }
    method entry($/) {
        make RangeMap.new(src => $<src>.made, des => $<des>.made,
                          len => $<len>.made)
    }
    method amap($/) {
        my @rs;
        for $<entry>.List -> $e {
            @rs.push($e.made);
        }
        make AlmanacMap.new(from => $<src-name>.Str, to => $<des-name>.Str,
                            ranges => @rs)}
    method maps($/) {
        my %sms;
        for $<amap> -> $m {
            my $mm = $m.made;
            %sms{$mm.from} = $mm;
        }
        make %sms;
    }

    method TOP($/) {
        my @seeds = $<seed-data>.split(' ', :skip-empty).map: *.Int;
        make Almanac.new(seeds => @seeds, src-maps => $<maps>.made);
    }
}
