export function display(dataURL) {
  var $img = document.createElement("img");
  $img.src = dataURL;
  $img.style =
    "position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);max-width:100%;max-height:100%;z-index:1010;";
  $img.id = "qrpu.sh#img";

  var $overlay = document.createElement("div");
  $overlay.style =
    "z-index:1000;position:fixed;top:0;left:0;width:100%;height:100%;max-width:100%;max-height:100%;background:white;opacity:0.6;";
  $overlay.id = "qrpu.sh#overlay";

  function close() {
    // Don't know why I need to re pull out of the DOM
    // $img = document.getElementById("qrpu.sh#img").remove();
    // $overlay = document.getElementById("qrpu.sh#overlay").remove();
    $img.parentElement.removeChild($img);
    $overlay.parentElement.removeChild($overlay);
  }
  $overlay.onclick = close;

  document.body.append($img);
  document.body.append($overlay);
  return { close };
}
