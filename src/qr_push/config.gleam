import gleam/int
import config/config.{get_env, required}

pub type Config {
  Config(port: Int)
}

fn string(s) {
  Ok(s)
}

pub fn from_env() {
  let env = get_env()

  let Ok(port) = required(env, "PORT", int.parse)

  Ok(Config(port: port))
}
