import std.stdio;
import core.thread;
import core.atomic;

__gshared int unsafeCounter;
shared int safeCounter;

void incrementCounters()
{
    foreach(i; 0 .. 100_000)
    {
        // Unsynchronized update may race
        unsafeCounter++;

        // Atomic update on shared counter
        atomicOp!"+="(safeCounter, 1);
    }
}

void main()
{
    auto t1 = new Thread(&incrementCounters);
    auto t2 = new Thread(&incrementCounters);
    t1.start();
    t2.start();
    t1.join();
    t2.join();

    writeln("unsafeCounter: ", unsafeCounter);
    // Cast to read from shared
    writeln("safeCounter: ", cast(int)safeCounter);
}
