import std.stdio;
import std.net.curl;
import std.json;
import std.array : appender;
import std.algorithm.mutation : move;
import std.uuid : randomUUID;

/// Setup authentication using a dummy bearer token.
void setupHttpByAuthConfig(ref HTTP http)
{
    auto token = randomUUID().toString();
    http.addRequestHeader("Authorization", "Bearer " ~ token);
}

/// Returns an HTTP instance with JSON headers added.
HTTP makeJsonHttp(string url)
{
    auto http = HTTP(url);
    setupHttpByAuthConfig(http);
    http.addRequestHeader("Accept", "application/json; charset=utf-8");
    http.addRequestHeader("Content-Type", "application/json");
    return move(http); // avoid copying the handle
}

void main()
{
    // GET example using shared setup
    auto getHttp = makeJsonHttp("https://httpbin.org/get");
    auto getBody = appender!string();
    getHttp.onReceive = (ubyte[] data)
    {
        getBody.put(cast(string) data);
        return data.length;
    };
    getHttp.perform();
    writeln("GET response: ", getBody.data);

    // POST example using the same setup
    auto postHttp = makeJsonHttp("https://httpbin.org/post");
    postHttp.method = HTTP.Method.post;
    postHttp.postData = "{\"hello\":\"world\"}";

    auto postBody = appender!string();
    postHttp.onReceive = (ubyte[] data)
    {
        postBody.put(cast(string) data);
        return data.length;
    };
    postHttp.perform();
    writeln("POST response: ", postBody.data);
}
