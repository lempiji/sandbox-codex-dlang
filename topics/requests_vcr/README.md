# Requests VCR

Implements a small VCR-like interceptor for the `requests` library. The first
run performs a POST to `https://httpbin.org/post` and stores the response in
`cassette.json`. Subsequent runs read the cached response instead of hitting the
network.

Run with `dub run`.
