# Destructor Call Counts: Design Note

This note outlines scenarios to confirm when destructors fire in D, the constructs involved, and how we will exercise each path so counts can be observed with a shared counter.

| Scenario | Construct | Expected destructor count rationale | How to exercise |
| --- | --- | --- | --- |
| Automatic value on scope exit | `struct` with a destructor stored as a local variable | One destructor call when the scope ends because the instance has a single lifetime and no copying is involved. | Call a helper function that declares the struct and returns immediately; print the counter after the call. |
| Return-by-value handoff | `struct` returned by value, captured by a caller variable | NRVO/move elides temporary destruction; exactly one call occurs when the caller’s bound variable leaves scope. | Factory function builds the struct and returns it; caller binds it to a local and exits the scope while reporting the counter. |
| Loop-created temporaries | `struct` constructed inside a `foreach`/`for` loop body | Each iteration constructs a fresh value whose lifetime ends at the end of the iteration, so destructor calls equal the iteration count. | Run a loop for a fixed number of iterations (e.g., 5) and print the counter after the loop. |
| Exception unwinding | `struct` created just before throwing | The stack object is cleaned up during unwinding, so the destructor fires once even though control flow jumps to `catch`. | In a function, create the struct then `throw`; catch the exception outside and inspect the counter. |
| Deterministic class cleanup | `scope` class instance with a destructor | `scope` ensures the GC-backed class is destroyed at scope exit, yielding one destructor call for the single instance. | Instantiate the class with `scope` inside a helper; upon leaving the scope, read the counter to confirm one invocation. |

### Planned summary statement (for confirmation in the example README)
Once measurements are captured, the README will summarize them as:

> デストラクタ呼び出し回数 = 生成したインスタンス数（スコープを抜ける・`scope` 解放・例外巻き戻しを含む）に対し、各インスタンスが一度迎える寿命の終端の合計

This phrasing keeps the emphasis on “one call per instance per completed lifetime,” regardless of whether the scope ends normally, via loop iteration boundaries, or through exception unwinding.
