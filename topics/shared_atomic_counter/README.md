# Shared Atomic Counter

Demonstrates how to safely increment a shared value from multiple threads using `core.atomic`.
The `counter` variable is declared as `shared` and each thread increments it via `atomicOp!"+="`.

Run with `dub run`.
