import * as Channel from "./channel.js";
import * as Overlay from "./overlay.js";

const defaults = { display: "overlay" };
export async function openChannel(options) {
  const { redirect, display } = Object.assign({}, defaults, options);
  const { url, dataURL, messagePromise } = await Channel.open(redirect);

  var close;
  function displayOverlay() {
    if (close) {
      return;
    }
    close = Overlay.display(dataURL).close;
  }
  if (display) {
    displayOverlay();
  }
  return {
    url,
    dataURL,
    displayOverlay,
    close: function() {
      close();
      close = undefined;
    },
    receive: async function() {
      const message = await messagePromise;
      if (close) {
        console.log("CLOSING");
        close();
      }
      return message;
    }
  };
}

export async function send(address, message) {
  const response = await fetch(address, {
    method: "POST",
    body: JSON.stringify(message)
  });
  console.log(response);
  console.log();
}
