console.log(window.location.search, "search");
export function open(options) {
  const { redirect: redirect } = options;
  // Params in here to keep the secret in the EventSource code.
  // Probably no more secure than in a private variable here
  const sourceURL = "/pull?redirect=" + redirect;
  const eventSource = new EventSource(sourceURL);

  return new Promise(function(resolve, reject) {
    // onmessage is only called if the type is "message"
    // https://stackoverflow.com/questions/9933619/html5-eventsource-listener-for-all-events
    eventSource.onmessage = function(event) {
      const { type, url } = JSON.parse(event.data);
      if (type != "qrpu.sh/init") {
        reject("Server emitted incorrect first event");
      }

      const message = new Promise(function(resolve, reject) {
        eventSource.onmessage = function(event) {
          // Use event type message becuase it's the default so one less field to send.
          // I think just throwing wont remove the handler
          if (event.type != "message") {
            throw "Unexpected event";
          }
          eventSource.close();
          resolve(JSON.parse(event.data));
        };
        eventSource.onerror = function(error) {
          if (eventSource.readyState == 2) {
            mailbox.close();
          }
        };
      });
      resolve({
        url: url,
        receive: function() {
          return message;
        }
      });
    };
    eventSource.onerror = function(error) {
      if (eventSource.readyState == 2) {
        reject("Failed to connect to '" + sourceURL + "'");
      }
    };
  });
  // Promise timeout in Gen Browser
}

export async function send(address, message) {
  const response = await fetch(address, {
    method: "POST",
    body: JSON.stringify(message)
  });
  console.log(response);
  console.log();
}
