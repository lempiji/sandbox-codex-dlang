# Shared Traits Introspection

Demonstrates checking if a value is `shared` at compile time.
The template `describe` uses `static if (is(T == shared))` to detect
whether its argument type has the `shared` qualifier.
Using `inout` on the parameter ensures the function returns a value
with the same qualifiers it was given.

Run with:

```
dub run
```
