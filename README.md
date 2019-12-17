## QR Push

# TODO pings, 204, display QR code

Sending messages to QR codes.

```js
const mailbox = await qrPush.mailbox({ redirect: "http://myapp.com/remote" });

mailbox.showOverlay();
const message = await mailbox.receive();

mailbox.address;
```

_remote.html_

```js
const response = await qrPush.send(message, { target: location.hash });
```

Put a version number in the package.json somewhere.
So breaking changes on OK error

In

https://qrp.sh#1234567890123456
32 + 64
8 + 7 + 16 = 31

Any params to go accross to the sender

1 hr time limit
time information in the client and stream
mihael on counter
Have a Docker image for running yourself.

Go is a language for CLI apps
Christmas challange every day
or seven languages. need to do kotlin and link in

## handle putting the id in a url

This doesn't work url on the server, well it does but only if I generate QR on the client. which totally does work

```js
qrPush.open({
  sender: id => {
    "http://myapp.com/remote?qrPushId=" + id;
  }
});
```

```js
qrPush.open({
  sender: id => {
    "http://myapp.com/remote?qrPushId=__QRPUSHID__" + id;
  }
});
```

## others

https://uqr.me/qr-code-generator/
http://goqr.me/qr-code-management/
https://qrd.by/features
