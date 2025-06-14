import std.stdio;
import std.array : Appender, appender;
import std.uri : encodeComponent;
import std.algorithm : canFind;
import std.string : endsWith, startsWith;

string buildUrl(Args...)(Args args)
{
    static if (Args.length == 0)
        static assert(false, "buildUrl requires at least one argument");

    enum hasParams = Args.length > 0 && is(Args[$ - 1] == string[string]);
    enum segCount = hasParams ? Args.length - 1 : Args.length;

    static assert(segCount > 0, "buildUrl requires at least one path segment");

    static if (hasParams)
        string[string] params = args[$ - 1];

    static foreach (i; 0 .. segCount)
        static assert(is(Args[i] == string),
            "Path segments must be strings");

    string base = args[0];
    static foreach (i; 1 .. segCount)
    {{
        auto seg = args[i];
        if (!base.endsWith("/"))
            base ~= "/";
        size_t j = 0;
        while (j < seg.length && seg[j] == '/') ++j;
        base ~= encodeComponent(seg[j .. $]);
    }}

    auto buf = appender!string();
    buf.put(base);

    static if (hasParams)
    {
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
    }
    return buf.data;
}

unittest
{
    // single segment without parameters
    assert(buildUrl("https://example.com/api") == "https://example.com/api");

    // two segments joined
    assert(buildUrl("https://example.com", "api") == "https://example.com/api");

    // segments with parameters
    string[string] p;
    p["q"] = "dlang";
    auto result = buildUrl("https://example.com", "search", p);
    assert(result.startsWith("https://example.com/search?"));
    assert(result.canFind("q=dlang"));

    // segments with three path components and params
    string[string] p2;
    p2["foo"] = "bar";
    auto r2 = buildUrl("https://example.com", "api", "v1", p2);
    assert(r2.startsWith("https://example.com/api/v1?"));
    assert(r2.canFind("foo=bar"));

    // segment with spaces should be encoded
    auto r3 = buildUrl("https://example.com", "with space");
    assert(r3 == "https://example.com/with%20space");

    // compile-time: calling with only params AA should fail
    static assert(!__traits(compiles, buildUrl(["k":"v"])));
}

void main()
{
    string[string] params;
    params["search"] = "D language";
    params["page"] = "1";
    params["tags"] = "url encoding";

    writeln(buildUrl("https://example.com/api", params));
}
