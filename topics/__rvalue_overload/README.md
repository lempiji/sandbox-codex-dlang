# `__rvalue` Overload Selection

This example shows how overload resolution prefers `ref` parameters for
lvalues, how `__rvalue` can force the non-`ref` overload, and how
`__rvalue` on a `ref` return changes how a caller sees that result.

`app.d` defines two `foo` overloads (`foo(T)` and `foo(ref T)`), two
functions that return `ref T` (one regular and one annotated with
`__rvalue`), and a resource-like `Tracer` that logs constructions,
moves, and destructor ordering. Calls in `main` log which overload is
chosen for:

- a named variable (`x`), the same variable wrapped with `__rvalue`, and a
  temporary `T(2)`
- a `ref` return without `__rvalue` versus a `ref` return marked as
  `__rvalue`
- a `Tracer` passed by value or `__rvalue` to see when destructors run
  and how using a moved-from instance is reported

Run the sample with:

```
dub run
```
