import gleam/int
import config/config.{get_env, required}

pub type Config {
  Config(port: Int, frontend_url: String, api_url: String)
}

fn string(s) {
  Ok(s)
}

pub fn from_env() {
  let env = get_env()

  let Ok(port) = required(env, "PORT", int.parse)
  let Ok(frontend_url) = required(env, "FRONTEND_URL", string)
  let Ok(api_url) = required(env, "API_URL", string)

  Ok(Config(port: port, frontend_url: frontend_url, api_url: api_url))
}
