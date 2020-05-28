(async function(){
  console.log("hello")

  var response = await fetch("http://localhost:8080/start", {
    method: "POST",
    body: "target=http://localhost:7000/foo"
  })
  console.log(response);
  var data = await response.formData()

  pull_token = data.get("pull_token")
  redirect_uri = data.get("redirect_uri")

  console.log(redirect_uri);
  var [_, push_token] = redirect_uri.split(".sh/")
  console.log(push_token);

  var pullPromise = fetch("http://localhost:8080/pull", {
    headers: {
      authorization: "Bearer " + pull_token
    }
  })

  var response = await fetch("http://localhost:8080/push", {
    method: "POST",
    headers: {
      authorization: "Bearer " + push_token
    },
    body: "Hello there"
  })
  console.log(response);

  var response = await pullPromise
  console.log(response);
  console.log(await response.text());
}())
