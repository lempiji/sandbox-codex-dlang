# Shared Ring Buffer

This example demonstrates a simple single-producer single-consumer ring buffer built on `shared` memory. The producer thread pushes numbers into the buffer while the consumer thread pops them out, using `core.atomic` operations to synchronize access without locks.

Run with:

```
dub run
```
