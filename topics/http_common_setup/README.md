# HTTP Common Setup

Shows how to factor out common HTTP configuration when communicating with
services such as `httpbin.org`. The example sets authorization and JSON
headers once and reuses the setup for both GET and POST requests.

Run with `dub run`.
