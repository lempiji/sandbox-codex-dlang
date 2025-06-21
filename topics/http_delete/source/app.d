import std.stdio;
import std.net.curl;
import std.json;
import std.array : appender;

void main()
{
    auto http = HTTP("https://httpbin.org/delete");
    http.method = HTTP.Method.del;

    string[string] headers;
    auto body = appender!string();

    http.onReceiveHeader = (in char[] key, in char[] value)
    {
        headers[key.idup] = value.idup;
    };

    http.onReceive = (ubyte[] data)
    {
        body.put(cast(string)data);
        return data.length;
    };

    http.perform();

    writeln("Status line: ", http.statusLine);

    writeln("-- Response Headers --");
    foreach (k, v; headers)
        writeln(k, ": ", v);

    writeln("-- JSON Body --");
    auto json = parseJSON(body.data);
    writeln(json.toPrettyString());
}
