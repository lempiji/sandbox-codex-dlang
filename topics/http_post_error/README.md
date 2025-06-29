# HTTP POST Error Example

Performs an HTTP `POST` request to `https://httpbin.org/post` with JSON data. The request sets `failOnError` to `false` so a non-2xx status will not raise an exception. After reading the response body it parses the JSON and prints the status code and parsed data.

Run with:

```
dub run
```
