import std.stdio;
import std.conv : to;
import core.thread;
import core.sync.rwmutex;

shared class KeyValueStore
{
    string[string] data;
    shared ReadWriteMutex lock;

    this() shared
    {
        lock = new shared ReadWriteMutex();
    }

    string get(string key) shared
    {
        synchronized(lock.reader)
        {
            auto p = key in data;
            return p ? *p : "";
        }
    }

    void put(string key, string val) shared
    {
        synchronized(lock.writer)
        {
            data[key] = val;
        }
    }
}

void main()
{
    auto store = new shared KeyValueStore();

    // writer thread
    auto writer = new Thread({
        foreach(i; 0 .. 1000)
        {
            store.put("count", to!string(i));
        }
    });

    // reader threads
    Thread[] readers;
    foreach(i; 0 .. 2)
    {
        readers ~= new Thread({
            foreach(j; 0 .. 1000)
            {
                store.get("count");
            }
        });
    }

    writer.start();
    foreach(r; readers) r.start();

    writer.join();
    foreach(r; readers) r.join();

    writeln("Final value: ", store.get("count"));
}
