import std.stdio;
import core.atomic;
import core.thread;

shared int counter;

void incrementLoop(int iterations)
{
    foreach(_; 0 .. iterations)
    {
        atomicOp!"+="(counter, 1);
    }
}

void main()
{
    enum iterations = 100_000;
    enum numThreads = 4;

    Thread[] threads;
    foreach(_; 0 .. numThreads)
    {
        threads ~= new Thread(() { incrementLoop(iterations); });
    }

    foreach(t; threads)
        t.start();
    foreach(t; threads)
        t.join();

    writeln("Final counter: ", counter);
}
