use RangeMap;

class MyRange is Range {
    has Int $.id; #a number to keep track of source

    method maps-to(RangeMap $m --> Array[MyRange]) {
        ...
    }
}

