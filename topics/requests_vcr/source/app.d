/**
    Example demonstrating simple VCR-like caching for HTTP POST
    requests using the `requests` library.

    First run will hit https://httpbin.org/post and store the
    JSON response in `cassette.json`.  Subsequent runs will read
    and output the cached response instead of performing a new
    network request.  Edit `cassette.json` manually to see the
    interception effect; the modified text will be printed without
    reaching httpbin.
*/
module app;

import std.stdio;
import std.file : exists, readText, write;
import std.json;
import requests;
import requests.http : HTTPResponse;

class VcrInterceptor : Interceptor
{
    string cassette;
    this(string cassette) { this.cassette = cassette; }

    override Response opCall(Request r, RequestHandler next)
    {
        if (exists(cassette))
        {
            auto data = parseJSON(readText(cassette)).object;
            auto resp = new HTTPResponse();
            resp.responseBody.put(cast(ubyte[])data["body"].str);
            auto hdr = resp.responseHeaders;
            foreach (k, v; data["headers"].object)
                hdr[k] = v.str;
            // code and URIs are not used in this example
            return resp;
        }

        auto rs = next.handle(r);
        JSONValue j;
        j["body"] = cast(string)rs.responseBody.data;
        JSONValue hdrs = parseJSON("{}");
        foreach (k, v; rs.responseHeaders)
            hdrs.object[k] = v;
        j["headers"] = hdrs;
        write(cassette, j.toString());
        return rs;
    }
}

void main()
{
    enum url = "https://httpbin.org/post";
    enum cassette = "cassette.json";

    requests.addInterceptor(new VcrInterceptor(cassette));

    auto rq = Request();
    auto rs = rq.post(url, "d=lang", "application/x-www-form-urlencoded");
    writeln(cast(string)rs.responseBody.data);

    // Modify the cassette and show that the cached response changes
    auto data = parseJSON(readText(cassette));
    data["body"] = "modified response";
    write(cassette, data.toString());

    rs = rq.post(url, "d=lang", "application/x-www-form-urlencoded");
    writeln(cast(string)rs.responseBody.data);
}
