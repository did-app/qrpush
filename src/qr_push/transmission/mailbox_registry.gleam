import process/process
import process/supervisor/set_supervisor
import process/process.{From, Infinity}

pub type Messages {
  // Could forward the Get message and reply from child!
  // Could return {pid, target} like elixir registry
  // THis is only replacing whereis functionality
  // without init function starting is quick and therefore safe to do from central point.
  // Normal Gen init process can wait and therefore slow down a central registry of supervisor
  // TODO String -> Mailbox Pid
  GetMailbox(From(String), Int)
}

// TODO DOWN
// If storing Pid(value)
external type Registry(a, b)

external fn mk_value(fn(process.Pid(a)) -> b) -> Int =
  "" ""

// Get mailbox can't lazily create because we want information we don't have
// Want to create child where the central registry process gives us the value for an id
// New(fn(pid) -> Thing, maybe pids could even be different as long as Thing was a consistent Enum)
// I like keeping process identical, though it won't last, and putting key in registry.
fn loop(receive, mailbox_supervisor) {
  case receive(Infinity) {
    Ok(GetMailbox(from, id)) -> {
      // pull from map
      // else start undersupervisor
      let Ok(p) = set_supervisor.start_child(mailbox_supervisor)
      process.reply(from, "5")
      // TODO Monitor p
      loop(receive, mailbox_supervisor)
    }
  }
}

fn init(receive, mailbox_supervisor) {
  loop(receive, mailbox_supervisor)
}

pub fn spawn_link(mailbox_supervisor) {
  process.spawn_link(init(_, mailbox_supervisor))
}
