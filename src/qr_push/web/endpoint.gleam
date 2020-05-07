import midas
import qr_push/config.{Config}
import qr_push/web/router

pub fn spawn_link(config) {
  let Config(port: port) = config
  midas.spawn_link(router.handle_request(_, config), port)
}
