# `__rvalue` Overload Selection

This sample demonstrates how `__rvalue` lets you tell the compiler to
treat an expression like a temporary even when it is not one. The
program exercises overload resolution, `ref` returns, move/copy
constructors, and destructor ordering to make the differences visible in
the console output.

Run the sample with:

```
dub run
```

## What the code sets up

`source/app.d` defines:

- Two overloads `foo(T)` and `foo(ref T)` to show how `__rvalue` changes
  which overload wins during resolution.
- Two ref-returning helpers: `produceRef()` (plain `ref`) and
  `produceRefRvalue()` (`ref` return annotated with `__rvalue`) to show
  how call sites perceive the returned value.
- Two tracer types:
  - `Tracer` has a move constructor and destructor logging so you can see
    when a move is selected.
  - `TracerNoMove` lacks a move constructor and therefore exercises the
    copy-only path even when wrapped in `__rvalue`.
- Small helpers `consumeByValue` and `observeRef` that log parameter
  usage and permit observing moved-from objects.

## How `__rvalue` changes behavior

### Parameter overload selection

- Calling `foo(x)` with a named variable (`x`) selects `foo(ref T)`
  because a named variable is an lvalue.
- Wrapping the same variable as `foo(__rvalue(x))` forces the call to
  prefer the by-value overload, as if a temporary were passed.
- Passing a temporary such as `foo(T(2))` also calls the by-value
  overload because a temporary cannot bind to a `ref` parameter.

### `ref` returns with and without `__rvalue`

- A plain `ref` return (`produceRef()`) behaves like an lvalue, so
  calling `foo(produceRef())` prefers the `ref` overload and the result
  can bind to a `ref` variable.
- Marking the function as `__rvalue` (`produceRefRvalue() __rvalue`)
  makes the call expression behave like a temporary. `foo` therefore
  selects the by-value overload, and attempting to bind the result to a
  `ref` variable fails to compile.
- Wrapping either call in `__rvalue(...)` also forces the by-value
  overload and prevents binding to a `ref` variable, mirroring the
  behavior of a temporary value.

### Move/copy constructor selection

- `Tracer` shows the difference between initialization/assignment from a
  named lvalue versus a value wrapped in `__rvalue(...)`. The wrapped
  version selects the move constructor or move-aware assignment operator
  and marks the source as moved-from (the destructor warns if it would
  double-release).
- Constructing or assigning from a true temporary (`Tracer(200)` or
  `Tracer(300)`) also uses the move path.
- `TracerNoMove` lacks a move constructor, so even when an lvalue is
  wrapped in `__rvalue`, the compiler falls back to copy/postblit paths
  for initialization and assignment.

### Destructor timing for by-value parameters

- Passing a named lvalue by value copies the original, so when the
  function returns the caller still owns the original, and the copy is
  destroyed inside the callee.
- Passing `__rvalue(named)` moves the object into the parameter. The
  caller is left with a moved-from object (value set to `-1` in this
  sample), and the destructor runs on the moved-from instance, emitting a
  warning that a double release would have occurred.

### Observing moved-from state

- After moving a `Tracer` into a by-value parameter, attempting to use
  the original via `ref` demonstrates that its internal state has been
  updated to indicate it was moved. The sample prints a warning when its
  destructor runs.
- Performing the same observation on an intact lvalue shows normal,
  safe mutation through the `ref` parameter, highlighting the semantic
  difference introduced by `__rvalue`.
