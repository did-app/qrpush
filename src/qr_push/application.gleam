import gleam/atom
import process/supervisor/rest_for_one
import qr_push/config
// import qr_push/transmission/mailbox_supervisor
// import qr_push/transmission/mailbox_registry
import qr_push/web/endpoint

fn init() {
  let Ok(config) = config.from_env()

  rest_for_one.One(
    // fn() { client.spawn_link(config) },
    fn() { endpoint.spawn_link(config) },
  )
}

pub fn start(_start, _args) {
  Ok(rest_for_one.spawn_link(init))
}

pub fn stop(_) {
  atom.create_from_string("ok")
}
