import std.conv : to;
import std.stdio;

struct T
{
    int value;
}

struct Tracer
{
    int value;

    this(int value)
    {
        this.value = value;
        writeln("Tracer value ctor: " ~ this.value.to!string);
    }

    this(return scope Tracer rhs)
    {
        writeln("Tracer move ctor from rvalue: " ~ rhs.value.to!string);
        value = rhs.value;
        rhs.value = -1; // mark the moved-from state
    }

    this(this)
    {
        writeln("Tracer postblit copy from: " ~ value.to!string);
    }

    this(ref return scope const Tracer rhs)
    {
        writeln("Tracer copy ctor from lvalue: " ~ rhs.value.to!string);
        value = rhs.value;
    }
}

// Overload set to see how ref-qualified parameters interact with rvalues.
void foo(T)(T value)
{
    writeln("foo(T) overload (by value)");
}

void foo(T)(ref T value)
{
    writeln("foo(ref T) overload");
}

// Returning by ref normally produces an lvalue, so overload resolution can prefer ref.
ref T produceRef()
{
    static T stored = T(10);
    writeln("produceRef -> returning ref without __rvalue attribute");
    return stored;
}

// Marking the return as __rvalue means the call is treated like a temporary.
ref T produceRefRvalue() __rvalue
{
    static T stored = T(20);
    writeln("produceRefRvalue -> returning ref with __rvalue attribute");
    return stored;
}

void main()
{
    writeln("=== Parameter overload selection ===");
    T x = T(1);

    // A named variable is an lvalue, so the ref overload is chosen.
    foo(x);

    // Wrapping with __rvalue makes the same variable behave like a temporary, selecting foo(T).
    foo(__rvalue(x));

    // A temporary (rvalue) cannot bind to ref, so foo(T) is invoked.
    foo(T(2));

    writeln("\n=== Ref return vs __rvalue ref return ===");

    // The ref return acts like an lvalue, so the ref overload is selected.
    foo(produceRef());

    // The __rvalue attribute on the ref return causes the value overload to win instead.
    foo(produceRefRvalue());

    writeln("\n=== Move/postblit/copy tracing ===");

    Tracer xTrace = Tracer(100);

    writeln("-- initialization from named lvalue --");
    Tracer fromX = xTrace;

    writeln("-- initialization from __rvalue(xTrace) --");
    Tracer fromRvalue = __rvalue(xTrace);

    writeln("-- initialization from temporary --");
    Tracer fromTemp = Tracer(200);

    const Tracer constTrace = Tracer(400);
    writeln("-- initialization from const lvalue (copy ctor) --");
    Tracer fromConst = constTrace;

    writeln("-- explicit copy constructor call --");
    Tracer fromCopy = void;
    fromCopy.__ctor(constTrace);

    Tracer target = Tracer(0);

    writeln("-- assignment from named lvalue --");
    target = xTrace;

    writeln("-- assignment from __rvalue(xTrace) --");
    target = __rvalue(xTrace);

    writeln("-- assignment from temporary --");
    target = Tracer(300);
}
