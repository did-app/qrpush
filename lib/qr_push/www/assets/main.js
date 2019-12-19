import * as Channel from "./channel.js";
import * as Overlay from "./overlay.js";

const defaults = { display: "overlay" };
export async function openChannel(options) {
  const { redirect, display } = Object.assign({}, defaults, options);
  const { url, dataURL, message } = await Channel.open(redirect);

  function displayOverlay() {
    return Overlay.display(dataURL);
  }
  const close = display ? displayOverlay().close : undefined;
  return {
    url,
    dataURL,
    displayOverlay,
    close,
    receive: async function() {
      return await message;
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
