pub external type SequenceRef
pub external type Ok

external fn do_new(Int, List(Nil)) -> SequenceRef =
  "counters" "new"

external fn do_add(SequenceRef, Int, Int) -> Ok =
  "counters" "add"

external fn do_get(SequenceRef, Int) -> Int =
  "counters" "get"

pub fn new() {
  do_new(1, [])
}

pub fn next(counter) {
  let _ = do_add(counter, 1, 1)
  do_get(counter, 1)
}
