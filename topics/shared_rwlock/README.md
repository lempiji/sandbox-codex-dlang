# Shared Read/Write Lock

This example shows using `ReadWriteMutex` to protect a shared `KeyValueStore`.
Multiple reader threads can access the map concurrently while writer threads
acquire an exclusive lock. Because `ReadWriteMutex` is used, the code accesses
shared data without any casts.

Run with:

```
dub run
```
