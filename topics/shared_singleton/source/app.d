import std.stdio;
import core.thread;
import core.sync.mutex;

class CounterSingleton
{
    private static shared CounterSingleton _instance;
    private static shared Mutex initMutex;
    private int value;

    shared static this()
    {
        initMutex = new shared Mutex();
    }

    private this() shared {}

    static shared(CounterSingleton) instance()
    {
        if(_instance is null)
        {
            synchronized(initMutex)
            {
                if(_instance is null)
                    _instance = new shared CounterSingleton();
            }
        }
        return _instance;
    }

    void increment() shared
    {
        synchronized(initMutex)
        {
            (cast()value)++;
        }
    }

    int getValue() shared
    {
        synchronized(initMutex)
        {
            return (cast()value);
        }
    }
}

void worker()
{
    auto inst = CounterSingleton.instance();
    foreach(i; 0 .. 1000)
        inst.increment();
}

void main()
{
    auto inst = CounterSingleton.instance();

    Thread[] threads;
    foreach(i; 0 .. 4)
        threads ~= new Thread(&worker);

    foreach(t; threads) t.start();
    foreach(t; threads) t.join();

    writeln("Final count: ", inst.getValue());
}
