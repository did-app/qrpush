import gleam/io
import gleam/iodata.{Iodata}
import gleam/list
import gleam/option.{Option, Some}
import gleam/string
import gleam/uri.{Uri}
import gleam/http
import process/process.{Wait, Infinity}
import registry/local
import qr_push/config.{Config}
import qr_push/sequence
import qr_push/mailbox_supervisor
import qr_push/web/router
import gleam/should

fn setup() {
  let sequence_ref = sequence.new()
  let registry = local.spawn_link()
  let supervisor = mailbox_supervisor.spawn_link()
  let config = Config(port: 0, frontend_url: "www.qrpush.test")
  tuple(sequence_ref, registry, supervisor, config)
}

pub external fn unsafe_receive(Wait) -> Option(http.Response(Iodata)) =
  "process_native" "do_receive"

pub fn send_message_to_follower_test() {
  let tuple(sequence_ref, registry, supervisor, config) = setup()
  let request = http.request(http.Post, "http://www.qrpush.test/start")
    |> http.set_body("target=http://other.test/sender.html")

  let response = router.handle_request(
    request,
    sequence_ref,
    registry,
    supervisor,
    config,
  )
  should.equal(response.head.status, 200)
  let Ok(form_data) = http.get_form(response)
  let Ok(pull_token) = list.key_find(form_data, "pull_token")
  let Ok(redirect_uri) = list.key_find(form_data, "redirect_uri")
  let request = http.request(http.Get, redirect_uri)
    |> http.set_body("")

  let response = router.handle_request(
    request,
    sequence_ref,
    registry,
    supervisor,
    config,
  )
  io.debug(response)
  should.equal(response.head.status, 303)
  let Some(target) = http.get_header(response, "location")
  should.equal(
    True,
    string.starts_with(target, "http://other.test/sender.html?"),
  )
  let Ok(Uri(query: Some(query), ..)) = uri.parse(target)
  let Ok([tuple("qrpu.sh", push_token)]) = uri.parse_query(query)

  let test = process.unsafe_self()
  process.spawn_link(
    fn(_receive) {
      let request = http.request(http.Get, "http://www.qrpush.test/pull")
        |> http.set_header(
          "authorization",
          string.append("Bearer ", pull_token),
        )
        |> http.set_body("")
      let response = router.handle_request(
        request,
        sequence_ref,
        registry,
        supervisor,
        config,
      )
      process.send(test, response)
    },
  )

  process.sleep(200)
  let request = http.request(http.Post, "http://www.qrpush.test/push")
    |> http.set_header("authorization", string.append("Bearer ", push_token))
    |> http.set_body("Any content here")
  let response = router.handle_request(
    request,
    sequence_ref,
    registry,
    supervisor,
    config,
  )
  should.equal(response.head.status, 200)

  // NOTE can't specify types on let and have it work out the dot accessors
  let Some(response) = unsafe_receive(Infinity)
  should.equal(200, response.head.status)
  should.equal("Any content here", http.get_body(response))
}
