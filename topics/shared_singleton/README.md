# Shared Singleton

This sample demonstrates a lazily initialized singleton shared across threads.
`CounterSingleton` creates its single instance on first use inside a
`synchronized` block guarded by a mutex set up in `shared static this`.
Multiple threads obtain the singleton and increment a shared counter.

Run it with:

```
dub run
```
