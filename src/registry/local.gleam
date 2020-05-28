import gleam/map
import gleam/option.{Option, Some, None}
import process/process.{From, Pid, Ref, MonitorType, BarePid, ExitReason, Infinity}

// Use the same registry messages accross all
pub type Message(k, m) {
  Register(from: From(Option(Pid(m))), key: k, create: fn() -> Pid(m))
  Lookup(from: From(Option(Pid(m))), key: k)
  Down(Ref, MonitorType, BarePid, ExitReason)
}

fn loop(receive, refs_map, keys_map) {
  case receive(Infinity) {
    Some(Register(from, key, create)) -> case map.get(keys_map, key) {
      Ok(existing) -> {
        process.reply(from, None)
        loop(receive, refs_map, keys_map)
      }
      Error(Nil) -> {
        let pid = create()
        let ref = process.monitor(pid)
        let keys_map = map.insert(keys_map, key, pid)
        let refs_map = map.insert(refs_map, ref, key)
        process.reply(from, Some(pid))
        loop(receive, refs_map, keys_map)
      }
    }
    Some(Lookup(from, key)) -> case map.get(keys_map, key) {
      Ok(existing) -> {
        process.reply(from, Some(existing))
        loop(receive, refs_map, keys_map)
      }
      Error(Nil) -> {
        process.reply(from, None)
        loop(receive, refs_map, keys_map)
      }
    }
    Some(Down(ref, _process, pid, _reason)) -> case map.get(refs_map, ref) {
      Ok(key) -> {
        let keys_map = map.delete(keys_map, key)
        let refs_map = map.delete(refs_map, ref)
        loop(receive, refs_map, keys_map)
      }
      Error(Nil) -> loop(receive, refs_map, keys_map)
    }
  }
}

pub fn spawn_link() {
  process.spawn_link(loop(_, map.new(), map.new()))
}

// returns Result(Option), None is because Key already registered, normal operation.
// error is for failure to contact registry, dead pid, or in larger systems no consensus.
// new_or_create works for returning existing value
// Return a Registered(pid), Existing(pid)
// Is it just OK(pid) | error Pid
pub fn register(registry, key, create) {
  process.call(registry, Register(_, key, create), Infinity)
}

pub fn lookup(registry, key) {
  process.call(registry, Lookup(_, key), Infinity)
}
// register_new
// register_replace (if pid what you do)
// update === register_replace(option)
// pub fn register(registry: Registry(a, b), key: a, create: fn(Option(b)) -> Option(b)) -> Result(b, Nil) {
// Option is an already started value response
// Ok(Ok(b) Exists)
// pub fn lookup()
// update(key, modify)
// Can have a call function that sends a Down message from registry if needed
