# Shared Singleton

This sample demonstrates a lazily initialized singleton shared across threads.
`CounterSingleton` creates its single instance on first use inside a
`synchronized` block guarded by a mutex set up in `shared static this`.
Multiple threads obtain the singleton and increment a shared counter.
The counter value is updated and read using `core.atomic` to ensure
thread-safe operations.

Run it with:

```
dub run
```
