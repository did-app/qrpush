// TODO rename sequence
pub external type CounterRef

pub external type Ok

// Don't use options
external fn do_new(Int, List(Nil)) -> CounterRef =
  "counters" "new"

external fn do_add(CounterRef, Int, Int) -> Ok =
  "counters" "add"

external fn do_get(CounterRef, Int) -> Int =
  "counters" "get"

pub fn new() {
  do_new(1, [])
}

pub fn next(counter) {
  let _ = do_add(counter, 1, 1)
  do_get(counter, 1)
}
