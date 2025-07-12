# gshared vs shared

Illustrates when to choose `shared` over `__gshared` for global variables.
Two threads increment an `__gshared` counter without synchronization and a
`shared` counter using `atomicOp`. The final values show that the
`__gshared` counter is prone to races while the `shared` counter is safe.

Run with `dub run`.
