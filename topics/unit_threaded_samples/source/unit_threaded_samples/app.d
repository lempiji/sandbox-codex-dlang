module unit_threaded_samples.app;

import core.thread : Thread;
import std.datetime : Duration, msecs;
import std.exception : enforce;
import std.format : format;
import std.stdio : writeln;

int add(int lhs, int rhs) @safe pure nothrow @nogc
{
    return lhs + rhs;
}

string greet(string name)
{
    return name.length ? format("Hello, %s!", name) : "Hello, world!";
}

void ensurePositive(int value)
{
    if (value < 0)
    {
        throw new Exception("guard should reject negatives");
    }
}

bool stabilizeAfterAttempts(ref int attempts, Duration waitTime, int succeedAt)
{
    Thread.sleep(waitTime);
    ++attempts;
    return attempts >= succeedAt;
}

version(unittest)
{
    import unit_threaded.assertions;
    import utattrs = unit_threaded.runner.attrs;

    alias Name = utattrs.Name;
    alias Values = utattrs.Values;
    alias AutoTags = utattrs.AutoTags;
    alias Flaky = utattrs.Flaky;
    alias ShouldFailWith = utattrs.ShouldFailWith;
    alias UnitTestAttr = utattrs.UnitTest;
    alias getValue = utattrs.getValue;

    @Name("addition with assertEqual")
    unittest
    {
        add(2, 3).shouldEqual(5);
    }

    @Name("data-driven greeting")
    @Values(["Ada", "Dlang", ""])
    @AutoTags
    unittest
    {
        auto name = getValue!string();
        auto expected = name.length ? format("Hello, %s!", name) : "Hello, world!";
        greet(name).shouldEqual(expected);
    }

    @Name("flaky check retried with wait")
    @Flaky(3)
    unittest
    {
        enum waitTime = 30.msecs;
        static int attempts;

        bool stabilized = false;
        foreach(_; 0 .. 3)
        {
            stabilized = stabilizeAfterAttempts(attempts, waitTime, 2);
            if (stabilized)
            {
                break;
            }
        }

        enforce(stabilized, format("Resource not ready after %s attempts", attempts));
    }

    @Name("negative values must throw")
    @ShouldFailWith!Exception("guard should reject negatives")
    @UnitTestAttr
    void ensurePositiveRejectsNegatives()
    {
        ensurePositive(-1);
    }
}

else void main()
{
    writeln("unit-threaded sample executable");
    writeln("add(2, 3) => ", add(2, 3));
    writeln("greet(\"D\") => ", greet("D"));
    writeln("Run `dub test` to exercise the unit-threaded test suite.");
}
