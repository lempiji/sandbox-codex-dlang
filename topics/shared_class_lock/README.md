# Shared Class Lock

Demonstrates guarding a shared class with a mutex so multiple threads can safely access it. The `balance` field is a `shared double` accessed via `core.atomic` operations inside the synchronized block. The program spawns two threads that deposit and withdraw from the same `BankAccount` instance and prints the resulting balance.

Run with:

```
dub run
```
