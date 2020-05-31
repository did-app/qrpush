import gleam/atom
import gleam/io
import process/supervisor/rest_for_one
import qr_push/config
import qr_push/sequence
import registry/local
import qr_push/mailbox_supervisor
import qr_push/web/endpoint

fn init() {
  let Ok(config) = config.from_env()
  io.println("Helooooooooooooooooooooooo")
  let sequence = sequence.new()

  // If supervisor dies, registry will empty.
  // if registry dies supervisor needs to be killed
  rest_for_one.Three(
    fn() { local.spawn_link() },
    fn(_registry) { mailbox_supervisor.spawn_link() },
    fn(registry, supervisor) {
      endpoint.spawn_link(sequence, registry, supervisor, config)
    },
  )
}

pub fn start(_start, _args) {
  Ok(rest_for_one.spawn_link(init))
}

pub fn stop(_) {
  atom.create_from_string("ok")
}
