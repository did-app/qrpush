import gleam/atom
import gleam/io
import process/supervisor/rest_for_one
import process/supervisor/set_supervisor
import qr_push/config
import qr_push/counter
// import qr_push/transmission/mailbox_supervisor
import registry/local as registry
import qr_push/mailbox
import qr_push/web/endpoint

fn init() {
  let Ok(config) = config.from_env()
  let counter = counter.new()
  io.println("Doing it......................................")

  // counter here
  // If supervisor dies, registry will empty.
  // if registry dies supervisor needs to be killed
  // supervisor last to keep webserver running,
  rest_for_one.Three(
    fn() { registry.spawn_link() },
    fn(registry) {
      set_supervisor.spawn_link(
        fn(args) {
          let tuple(target, pull_secret, push_secret) = args
          mailbox.spawn_link(target, pull_secret, push_secret)
        },
      )
    },
    // think I need supervisor for start link
    fn(registry, supervisor) {
      endpoint.spawn_link(counter, registry, supervisor, config)
    },
  )
}

pub fn start(_start, _args) {
  Ok(rest_for_one.spawn_link(init))
}

pub fn stop(_) {
  atom.create_from_string("ok")
}
