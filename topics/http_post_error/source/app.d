import std.stdio;
import std.net.curl;
import std.json;
import std.array : appender;
import std.typecons : No;

void main()
{
    auto http = HTTP("https://httpbin.org/post");
    http.method = HTTP.Method.post;
    http.addRequestHeader("Content-Type", "application/json");
    http.postData = "{\"foo\": \"bar\"}";

    auto body = appender!string();
    http.onReceive = (ubyte[] data)
    {
        body.put(cast(string) data);
        return data.length;
    };

    // Do not throw on HTTP errors
    http.perform(No.throwOnError);

    writeln("Status code: ", http.statusLine.code);
    auto json = parseJSON(body.data);
    writeln(json.toPrettyString());
}
