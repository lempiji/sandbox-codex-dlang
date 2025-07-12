# Shared Class Lock

Demonstrates guarding a shared class with a mutex so multiple threads can safely access it. The program spawns two threads that deposit and withdraw from the same `BankAccount` instance and prints the resulting balance.

Run with:

```
dub run
```
