import gleam/atom
import process/supervisor/rest_for_one
import process/supervisor/set_supervisor
import qr_push/config
// import qr_push/transmission/mailbox_supervisor
import qr_push/transmission/mailbox_registry
import qr_push/web/endpoint

fn start_mailbox() {
  todo
}

fn init() {
  let Ok(config) = config.from_env()

  rest_for_one.Three(
    fn() { set_supervisor.spawn_link(start_mailbox) },
    fn(mailbox_supervisor) { mailbox_registry.spawn_link(mailbox_supervisor) },
    fn(_, mailbox_registry) { endpoint.spawn_link(config) },
  )
}

pub fn start(_start, _args) {
  Ok(rest_for_one.spawn_link(init))
}

pub fn stop(_) {
  atom.create_from_string("ok")
}
