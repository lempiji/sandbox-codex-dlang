import std.conv : to;
import std.stdio;

struct T
{
    int value;
}

struct Tracer
{
    int value;
    bool released;

    this(int value)
    {
        this.value = value;
        released = false;
        writeln("Tracer value ctor: " ~ this.value.to!string);
    }

    this(return scope Tracer rhs)
    {
        writeln("Tracer move ctor from rvalue: " ~ rhs.value.to!string);
        value = rhs.value;
        released = rhs.released;
        rhs.value = -1; // mark the moved-from state
        rhs.released = true; // relinquish ownership so its destructor complains if invoked
    }

    this(this)
    {
        writeln("Tracer postblit copy from: " ~ value.to!string);
    }

    this(ref return scope const Tracer rhs)
    {
        writeln("Tracer copy ctor from lvalue: " ~ rhs.value.to!string);
        value = rhs.value;
        released = false;
    }

    ~this()
    {
        if (released)
        {
            writeln("Tracer destructor: double release detected for value=" ~ value.to!string);
            return;
        }

        writeln("Tracer destructor: releasing value=" ~ value.to!string);
        released = true;
    }
}

struct TracerNoMove
{
    int value;
    bool released;

    this(int value)
    {
        this.value = value;
        released = false;
        writeln("TracerNoMove value ctor: " ~ this.value.to!string);
    }

    this(this)
    {
        writeln("TracerNoMove postblit copy from: " ~ value.to!string);
    }

    this(ref return scope const TracerNoMove rhs)
    {
        writeln("TracerNoMove copy ctor from lvalue: " ~ rhs.value.to!string);
        value = rhs.value;
        released = false;
    }

    this(ref return scope TracerNoMove rhs)
    {
        writeln("TracerNoMove copy ctor from mutable rvalue: " ~ rhs.value.to!string);
        value = rhs.value;
        released = false;
    }

    this(scope TracerNoMove rhs)
    {
        writeln("TracerNoMove copy ctor from scoped rvalue: " ~ rhs.value.to!string);
        value = rhs.value;
        released = false;
    }

    ref TracerNoMove opAssign(ref TracerNoMove rhs)
    {
        writeln("TracerNoMove opAssign from lvalue: " ~ rhs.value.to!string);
        value = rhs.value;
        released = false;
        return this;
    }

    ref TracerNoMove opAssign(scope TracerNoMove rhs)
    {
        writeln("TracerNoMove opAssign from rvalue (copy path): " ~ rhs.value.to!string);
        value = rhs.value;
        released = false;
        return this;
    }

    ~this()
    {
        if (released)
        {
            writeln("TracerNoMove destructor: double release detected for value=" ~ value.to!string);
            return;
        }

        writeln("TracerNoMove destructor: releasing value=" ~ value.to!string);
        released = true;
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

void consumeByValue(Tracer t)
{
    writeln("consumeByValue -> holding value " ~ t.value.to!string);
}

void observeRef(ref Tracer t)
{
    writeln("observeRef -> seeing value " ~ t.value.to!string);
    t.value += 1;
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

    {
        writeln("-- plain calls --");

        // The ref return acts like an lvalue, so the ref overload is selected.
        foo(produceRef());

        // The __rvalue attribute on the ref return causes the value overload to win instead.
        foo(produceRefRvalue());

        writeln("-- wrapped in __rvalue(...) --");
        foo(__rvalue(produceRef()));
        foo(__rvalue(produceRefRvalue()));

        enum canBindRef = __traits(compiles, { ref T bound = produceRef(); });
        enum canBindRvalueRef = __traits(compiles, { ref T bound = produceRefRvalue(); });

        writeln("produceRef binds to ref variable: " ~ canBindRef.to!string);
        writeln("produceRefRvalue binds to ref variable: " ~ canBindRvalueRef.to!string);
    }

    writeln("\n=== Move/postblit/copy tracing ===");

    {
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

    writeln("\n=== Copy-only tracing (no move constructor available) ===");

    {
        TracerNoMove copyOnly = TracerNoMove(1000);

        writeln("-- initialization from named lvalue --");
        TracerNoMove copyFromX = copyOnly;

        writeln("-- initialization from __rvalue(copyOnly) --");
        TracerNoMove copyFromRvalue = void;
        copyFromRvalue.__ctor(__rvalue(copyOnly));

        writeln("-- initialization from temporary --");
        TracerNoMove copyFromTemp = TracerNoMove(1200);

        const TracerNoMove constCopyOnly = TracerNoMove(1400);
        writeln("-- initialization from const lvalue (copy ctor) --");
        TracerNoMove copyFromConst = constCopyOnly;

        writeln("-- explicit copy constructor call --");
        TracerNoMove copyFromCopyCtor = void;
        copyFromCopyCtor.__ctor(constCopyOnly);

        TracerNoMove copyTarget = TracerNoMove(0);

        writeln("-- assignment from named lvalue --");
        copyTarget = copyOnly;

        writeln("-- assignment from __rvalue(copyOnly) --");
        copyTarget = __rvalue(copyOnly);

        writeln("-- assignment from temporary --");
        copyTarget = TracerNoMove(1300);
    }

    writeln("\n=== Destructor ordering for by-value parameters ===");
    {
        writeln("-- call with named lvalue (copies) --");
        Tracer byValue = Tracer(500);
        consumeByValue(byValue);
        writeln("after consumeByValue(byValue) the source still owns: " ~ byValue.value.to!string);
    }

    {
        writeln("-- call with __rvalue named value (moves) --");
        Tracer byValue = Tracer(510);
        consumeByValue(__rvalue(byValue));
        writeln("after consumeByValue(__rvalue(byValue)) source is moved-from: " ~ byValue.value.to!string);
        writeln("moved-from instances warn on destruction while intact ones release cleanly");
    }

    writeln("\n=== Using moved-from instances ===");
    {
        Tracer refAfterMove = Tracer(600);
        consumeByValue(__rvalue(refAfterMove));
        writeln("-- attempting to use moved-from refAfterMove via ref --");
        observeRef(refAfterMove);
    }

    {
        Tracer intact = Tracer(700);
        writeln("-- using intact lvalue via ref --");
        observeRef(intact);
        writeln("Intact values keep ownership so ref use stays safe");
    }
}
