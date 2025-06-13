import std.stdio;
import std.array : Appender, appender;
import std.uri : encodeComponent;

string buildUrl(string baseUrl, string[string] params)
{
    auto buf = appender!string();
    buf.put(baseUrl);
    if (params.length != 0)
        buf.put("?");

    bool first = true;
    foreach (key, value; params)
    {
        if (!first) buf.put("&");
        buf.put(encodeComponent(key));
        buf.put("=");
        buf.put(encodeComponent(value));
        first = false;
    }
    return buf.data;
}

void main()
{
    string[string] params;
    params["search"] = "D language";
    params["page"] = "1";
    params["tags"] = "url encoding";

    writeln(buildUrl("https://example.com/api", params));
}
