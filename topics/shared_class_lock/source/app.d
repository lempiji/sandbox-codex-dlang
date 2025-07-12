import std.stdio;
import core.thread;
import core.sync.mutex;

shared class BankAccount
{
    private double balance;
    private shared Mutex mutex;

    this(double initialBalance = 0) shared
    {
        mutex = new shared Mutex();
        balance = initialBalance;
    }

    void deposit(double amount) shared
    {
        synchronized(mutex)
        {
            (cast()balance) += amount;
        }
    }

    void withdraw(double amount) shared
    {
        synchronized(mutex)
        {
            (cast()balance) -= amount;
        }
    }

    double getBalance() shared
    {
        synchronized(mutex)
        {
            return (cast()balance);
        }
    }
}

void main()
{
    auto account = new shared BankAccount(0);

    auto t1 = new Thread({ foreach(i; 0 .. 5000) account.deposit(1); });
    auto t2 = new Thread({ foreach(i; 0 .. 3000) account.withdraw(1); });

    t1.start();
    t2.start();
    t1.join();
    t2.join();

    writeln("Ending balance: ", account.getBalance());
}
