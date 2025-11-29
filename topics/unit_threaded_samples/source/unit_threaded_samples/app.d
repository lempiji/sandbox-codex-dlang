module unit_threaded_samples.app;

import core.thread : Thread;
import std.datetime : Duration, msecs;
import std.exception : collectException, enforce;
import std.format : format;
import std.stdio : writeln;

import unit_threaded;
import unit_threaded.assertions;
import utattrs = unit_threaded.runner.attrs;

alias Name = utattrs.Name;
alias Values = utattrs.Values;
alias AutoTags = utattrs.AutoTags;
alias Flaky = utattrs.Flaky;
alias ShouldFailWith = utattrs.ShouldFailWith;
alias UnitTestAttr = utattrs.UnitTest;
alias DontTest = utattrs.DontTest;
alias getValue = utattrs.getValue;

void assertEqual(T, U)(T actual, U expected)
{
    actual.shouldEqual(expected);
}

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
    enforce(value >= 0, "value must be non-negative");
}

bool stabilizeAfterAttempts(ref int attempts, Duration waitTime, int succeedAt)
{
    Thread.sleep(waitTime);
    ++attempts;
    return attempts >= succeedAt;
}

@UnitTestAttr
@Name("addition with assertEqual")
unittest
{
    assertEqual(add(2, 3), 5);
}

@UnitTestAttr
@Name("data-driven greeting")
@Values(["Ada", "Dlang", ""])
@AutoTags
unittest
{
    auto name = getValue!string();
    auto expected = name.length ? format("Hello, %s!", name) : "Hello, world!";
    assertEqual(greet(name), expected);
}

@UnitTestAttr
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

@UnitTestAttr
@Name("negative values must throw")
@ShouldFailWith!Exception("guard should reject negatives")
@DontTest
unittest
{
    try
    {
        ensurePositive(-1);
    }
    catch (Exception)
    {
    }
}

version(unittest) {}
else void main()
{
    writeln("unit-threaded sample executable");
    writeln("add(2, 3) => ", add(2, 3));
    writeln("greet(\"D\") => ", greet("D"));
    writeln("Run `dub test` to exercise the unit-threaded test suite.");
}
