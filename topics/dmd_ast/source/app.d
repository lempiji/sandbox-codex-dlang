import std.stdio;

import dmd.frontend;
import std.string : fromStringz;
import dmd.dmodule : Module;
import dmd.dsymbol;

void traverse(Dsymbol s, int indent = 0)
{
    foreach (_; 0 .. indent) write("  ");
    writeln(fromStringz(s.kind()), " ", fromStringz(s.toPrettyChars()));

    auto sc = s.isScopeDsymbol();
    if (sc && sc.members)
        foreach (member; *sc.members)
            traverse(member, indent + 1);
}

void main()
{
    initDMD();
    auto result = parseModule("source/app.d");
    auto mod = result.module_;
    traverse(mod);
}
