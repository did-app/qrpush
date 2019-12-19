// First event means no round trip if showing straigh away.
// But no one can scan the code in time
export function open(redirect) {
  // Params in here to keep the secret in the EventSource code.
  // Probably no more secure than in a private variable here
  // But we don't want to submit secret in URL when we connect
  const sourceURL = "/pull?redirect=" + redirect;
  const eventSource = new EventSource(sourceURL);

  return new Promise(function(resolve, reject) {
    // onmessage is only called if the type is "message"
    // https://stackoverflow.com/questions/9933619/html5-eventsource-listener-for-all-events
    eventSource.onmessage = function(event) {
      const { type, url, data_url } = JSON.parse(event.data);
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
            eventSource.close();
          }
        };
      });
      resolve({
        url: url,
        dataURL: data_url,
        message
      });
    };
    eventSource.onerror = function(error) {
      if (eventSource.readyState == 2) {
        eventSource.close();
        reject("Failed to connect to '" + sourceURL + "'");
      }
    };
  });
  // Promise timeout in Gen Browser
}
