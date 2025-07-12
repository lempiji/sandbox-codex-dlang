import std.stdio;

/// Returns val after printing whether it is shared
T describe(T)(inout T val)
{
    static if (is(T == shared))
        writeln("Value is shared");
    else
        writeln("Value is not shared");

    return val; // preserves qualifier
}

void main()
{
    int a = 1;
    shared int b = 2;

    auto ra = describe(a);
    auto rb = describe(b);

    writeln("Result a: ", ra);
    writeln("Result b: ", rb);
}
