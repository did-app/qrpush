import gleam/int
import gleam/io
import gleam/string

import midas
import qr_push/config.{Config}
import qr_push/web/router

pub fn spawn_link(counter, registry, supervisor, config) {
  let Config(port: port, ..) = config
  io.println(string.append("Starting server on port: ", int.to_string(port)))
  
  midas.spawn_link(
    router.handle_request(_, counter, registry, supervisor, config),
    port,
  )
}
