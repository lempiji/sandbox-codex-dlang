# sandbox-codex-dlang

This repository is a playground for exploring D language features.
Each topic should be placed in its own subdirectory under `topics/`.
Use `dub` or `dmd` as needed.

See `topics/hello_world` for a minimal example. Additional examples
include `topics/url_builder`, which demonstrates building a URL from
query parameters, and `topics/http_delete`, which shows how to issue an
HTTP DELETE request and capture the headers and JSON response. The
`topics/http_common_setup` example demonstrates reusing HTTP
configuration when talking to services like httpbin.org.
