module app;

import std.stdio;
// Earlier we tried `import std.typecons : Algebraic;` which failed with
// "module `std.typecons` import `Algebraic` not found". mir-ion expects
// `Algebraic` from `mir.algebraic`.
import mir.algebraic : Algebraic;
import mir.ser.json : serializeJson;
import mir.deser.json : deserializeJson;
import mir.serde : serdeAlgebraicAnnotation, serdeDiscriminatedField;

// --- Automatic tagging via @serdeAlgebraicAnnotation ---
// Without these annotations mir-ion raised:
// `Unexpected IonTypeCode for Algebraic!(A, B)` during deserialization.
@serdeAlgebraicAnnotation("A")
struct A { int a; }

@serdeAlgebraicAnnotation("B")
struct B { string b; }

alias AB = Algebraic!(A, B);

void autoAnnotationExample()
{
    AB valA = A(42);
    auto jsonA = serializeJson(valA);
    writeln("auto jsonA = ", jsonA);
    auto desA = deserializeJson!AB(jsonA);
    writeln("auto desA = ", desA);

    AB valB = B("hello");
    auto jsonB = serializeJson(valB);
    writeln("auto jsonB = ", jsonB);
    auto desB = deserializeJson!AB(jsonB);
    writeln("auto desB = ", desB);
}

// --- Custom field tagging via @serdeDiscriminatedField ---
// Attempted using @serdeDynamicAlgebraic but compile errors about delegate
// types halted that approach. Using @serdeDiscriminatedField stores the
// variant name under the provided field and works for dynamic recovery.
@serdeDiscriminatedField("kind", "C")
struct C { int c; }

@serdeDiscriminatedField("kind", "D")
struct D { string d; }

alias CD = Algebraic!(C, D);

void discriminatedFieldExample()
{
    CD val = C(7);
    auto json = serializeJson(val);
    writeln("disc json = ", json);
    auto des = deserializeJson!CD(json);
    writeln("disc des = ", des);
}

void main()
{
    autoAnnotationExample();
    writeln("-----");
    discriminatedFieldExample();
}

