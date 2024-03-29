---
layout: post
title: Signed request query string with Elixir
cover: /assets/images/covers/urban-astronaut-1500.jpg
tags:
- elixir
- phoenix
- signed-request
---

[SignedRequest](https://github.com/gravityblast/signed_request) is a simple [Elixir](http://elixir-lang.org/) module created to
sign request query strings using [HMAC](https://en.wikipedia.org/wiki/Hash-based_message_authentication_code).

Let's say `app-1` generates a page with a list of images dynamically generated by `app-2`.
Something like:

```html
<ul>
  <li>
    <img src="http://app-2.local/generate-image?type=png&size=200">
  <li>
  ...
</ul>
```

The `URL` of that image is viewable by users, this means that someone can maliciously open that link and change the size parameter
to a big number, making `app-2` blow up.

Instead of adding validations for each parameter we receive in the query string, we can just sign the request so that
`app-2` knows that the url has been generated `by app-1`.

Both apps share the same secret key:
```elixir
config :signed_request, :secret_key, "SECRET-KEY-SHARED-BY-BOTH-APPS"
```

`app-1` uses `SignedRequest.SignedURI` to sign the query string:
```elixir
query = %{type: :png, size: 200}
query_string = SignedRequest.SignedURI.encode_query(query)
```

The generated query string contains now a `sig` parameter:
```
"sig=addebd2454bded3770f09fe7bcd979e41b108385d80e02771734ab37e8b25641&size=200&type=png"
```

`app-2` can now decode the query string and validate the signature:
```elixir
case SignedRequest.SignedURI.decode_query(query) do
  {:ok, query} ->
    do_something(query)
  {:error, :invalid_hmac} ->
    render_404()
end
```
