import midas/http.{Request, Response, Get, Post, split_segments}

external fn body_length(String) -> Int =
  "erlang" "iolist_size"

pub fn handle_request(request, _config) {
  let Request(method: method, path: path, ..) = request

  case method, split_segments(path) {
    Get, [] -> Response(
      status: 200,
      headers: [tuple("content-type", "text/plain")],
      body: "Hello, world!\r\n",
    )
    _, _ -> Response(
      status: 404,
      headers: [tuple("content-type", "text/plain")],
      body: "Nothing here.\r\n",
    )
  }
}
