import std.stdio;
import core.thread;
import core.atomic;

enum bufferSize = 4;

shared int[bufferSize] buffer;
shared size_t head;
shared size_t tail;

void producer()
{
    foreach(i; 1 .. 11) // produce 10 numbers
    {
        while(true)
        {
            auto h = atomicLoad!(MemoryOrder.acq)(head);
            auto t = atomicLoad!(MemoryOrder.acq)(tail);
            auto nextTail = (t + 1) % bufferSize;
            if(nextTail == h)
            {
                Thread.yield();
                continue; // buffer full
            }
            atomicStore!(MemoryOrder.rel)(buffer[t], i);
            if(cas!(MemoryOrder.rel, MemoryOrder.acq)(&tail, t, nextTail))
                break;
        }
    }
}

void consumer()
{
    size_t count = 0;
    while(count < 10)
    {
        while(true)
        {
            auto h = atomicLoad!(MemoryOrder.acq)(head);
            auto t = atomicLoad!(MemoryOrder.acq)(tail);
            if(h == t)
            {
                Thread.yield();
                continue; // buffer empty
            }
            auto val = atomicLoad!(MemoryOrder.acq)(buffer[h]);
            auto nextHead = (h + 1) % bufferSize;
            if(cas!(MemoryOrder.rel, MemoryOrder.acq)(&head, h, nextHead))
            {
                writeln("Received: ", val);
                ++count;
                break;
            }
        }
    }
}

void main()
{
    head = 0;
    tail = 0;

    auto prod = new Thread(&producer);
    auto cons = new Thread(&consumer);

    cons.start();
    prod.start();

    prod.join();
    cons.join();
}

