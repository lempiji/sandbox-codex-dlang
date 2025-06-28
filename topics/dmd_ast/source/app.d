import std.stdio;

import dmd.frontend;
import std.string : fromStringz;
import dmd.dmodule : Module;
import dmd.dsymbol;

private Module initAndParse(string path)
{
    initDMD();
    auto result = parseModule(path);
    return result.module_;
}

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
    // Parse an external source file rather than this module itself
    auto mod = initAndParse("sample.d");
    traverse(mod);
}
