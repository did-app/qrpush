import gleam/io
import gleam/option.{Some}
import gleam/string
import gleam/http.{Request, Response, Get, Post, Options}
import process/supervisor/set_supervisor
import registry/local
import qr_push/counter
import qr_push/mailbox

external fn strong_rand_bytes(Int) -> String =
  "crypto" "strong_rand_bytes"

external fn base32_encode(String) -> String =
  "base32" "encode"

external fn base32_decode(String) -> String =
  "base32" "decode"

external fn int_to_32bits(Int) -> String =
  "qr_push_native" "int_to_32bits"

external fn int_from_32bits(String) -> Int =
  "qr_push_native" "int_from_32bits"

external fn binary_part(String, tuple(Int, Int)) -> String =
  "binary" "part"

external fn byte_size(String) -> Int =
  "erlang" "byte_size"

fn decode_token(token) {
  let decoded = base32_decode(token)
  io.debug(decoded)
  let mailbox_id = int_from_32bits(binary_part(decoded, tuple(0, 4)))
  let secret = binary_part(decoded, tuple(4, byte_size(decoded) - 4))
  tuple(mailbox_id, secret)
}

//
// @web_host (if(Mix.env() == :prod) do
//              # TODO https
//              "http://www.qrpu.sh"
//            else
//              "http://localhost:5000"
//            end)
//
// @impl Raxx.SimpleServer
// def handle_request(_request = %{method: :GET}, _state) do
//   redirect(@web_host)
// end
pub fn handle_request(request, counter_ref, registry, supervisor, _config) {
  case http.method(request), http.path_segments(request) {
    Get, [] -> http.response(200)
      |> http.set_body("API for qrpu.sh")
    Post, ["start"] -> {
      let mailbox_id = counter.next(counter_ref)
      let Ok([tuple("target", target)]) = http.get_form(request)
      let pull_secret = strong_rand_bytes(16)
      let push_secret = strong_rand_bytes(6)
      let pull_token = base32_encode(
        string.append(int_to_32bits(mailbox_id), pull_secret),
      )
      let push_token = base32_encode(
        string.append(int_to_32bits(mailbox_id), push_secret),
      )
      let Ok(
        pid,
      ) = set_supervisor.start_child(
        supervisor,
        tuple(target, pull_secret, push_secret),
      )
      let Ok(_pid) = local.register(registry, mailbox_id, fn() { pid })
      let data = [
          tuple("pull_token", pull_token),
          tuple("redirect_uri", string.append("http://qrpu.sh/", push_token)),
        ]
      // tuple("redirect_qr_code", "qrpu.sh/push_code"),
      // TODO QR code
      http.response(200)
      |> http.set_header("access-control-allow-origin", "*")
      |> http.set_form(data)
    }
    Get, ["pull"] -> {
      let Some(authorization) = http.get_header(request, "authorization")
      let True = string.starts_with(authorization, "Bearer ")
      let pull_token = string.slice(authorization, 7, 100)
      let tuple(mailbox_id, pull_secret) = decode_token(pull_token)
      let Ok(Some(pid)) = local.lookup(registry, mailbox_id)
      let Ok(message) = mailbox.pull(pid, pull_secret, 60000)
      http.response(200)
      |> http.set_header("access-control-allow-origin", "*")
      |> http.set_body(message)
    }
    Post, ["push"] -> {
      let Some(authorization) = http.get_header(request, "authorization")
      let True = string.starts_with(authorization, "Bearer ")
      let push_token = string.slice(authorization, 7, 100)
      let tuple(mailbox_id, push_secret) = decode_token(push_token)
      let Ok(Some(pid)) = local.lookup(registry, mailbox_id)
      let message = http.get_body(request)
      let Ok(Nil) = mailbox.push(pid, push_secret, message, 1000)
      http.response(200)
      |> http.set_header("access-control-allow-origin", "*")
      |> http.set_header("access-control-allow-headers", "authorization")
      |> http.set_body("")
    }
    Get, [push_token] -> {
      let tuple(mailbox_id, push_secret) = decode_token(push_token)
      let Ok(Some(pid)) = local.lookup(registry, mailbox_id)
      let Ok(target) = mailbox.redirect(pid, push_secret, 60000)
      // target + ?qrpu.sh=token
      // send whole url to make localdev easy.
      http.redirect("Todo")
    }
    Options, _ -> http.response(204)
      |> http.set_header("access-control-allow-origin", "*")
      |> http.set_header("access-control-allow-headers", "authorization")
      |> http.set_body("")

    Get, _ -> http.response(404)
      |> http.set_header("access-control-allow-origin", "*")
      |> http.set_body("Not found")
  }
}
// defp mask(secret) do
//   Base.encode32(:crypto.hash(:sha256, secret))
// end
//
// @doc """
// Compares the two binaries in constant-time to avoid timing attacks.
// See: http://codahale.com/a-lesson-in-timing-attacks/
// """
//
// def secure_compare(left, right) do
//   if byte_size(left) == byte_size(right) do
//     secure_compare(left, right, 0) == 0
//   else
//     false
//   end
// end
//
// import Bitwise, only: [|||: 2, ^^^: 2]
//
// defp secure_compare(<<x, left::binary>>, <<y, right::binary>>, acc) do
//   secure_compare(left, right, acc ||| x ^^^ y)
// end
//
// defp secure_compare(<<>>, <<>>, acc) do
//   acc
// end
