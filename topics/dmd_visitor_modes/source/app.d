import std.stdio;
import std.string : fromStringz;
import core.exception : AssertError;

import dmd.astbase : ASTBase;
import dmd.parse : Parser;
import dmd.errorsink : ErrorSinkStderr;
import dmd.globals;
import dmd.id;
import dmd.identifier;
import dmd.target;
import dmd.visitor.permissive;
import dmd.visitor.strict;
import std.file : readText;

private ASTBase.Module initAndParse(string fname)
{
    Id.initialize();
    global._init();
    target.os = Target.OS.linux;
    target.isX86_64 = (size_t.sizeof == 8);
    global.params.useUnitTests = true;
    ASTBase.Type._init();

    auto id = Identifier.idPool(fname);
    auto mod = new ASTBase.Module(&(fname.dup)[0], id, false, false);
    auto input = readText(fname) ~ "\0";

    scope p = new Parser!ASTBase(mod, input, false, new ErrorSinkStderr(), null, false);
    p.nextToken();
    mod.members = p.parseModule();

    return mod;
}

/// Visitor that prints function names; unsupported nodes are ignored.
extern(C++) class FuncFinderPermissiveVisitor : PermissiveVisitor!ASTBase
{
    alias visit = PermissiveVisitor!ASTBase.visit;
    override void visit(ASTBase.Module m)
    {
        foreach (sym; *m.members)
            sym.accept(this);
    }

    override void visit(ASTBase.FuncDeclaration f)
    {
        writeln("function (permissive): ", fromStringz(f.toChars()));
    }
}

/// Visitor that asserts when encountering unsupported nodes.
extern(C++) class FuncFinderStrictVisitor : StrictVisitor!ASTBase
{
    alias visit = StrictVisitor!ASTBase.visit;
    override void visit(ASTBase.Module m)
    {
        foreach (sym; *m.members)
            sym.accept(this);
    }

    override void visit(ASTBase.FuncDeclaration f)
    {
        writeln("function (strict): ", fromStringz(f.toChars()));
    }
}

void main()
{
    auto mod = initAndParse("sample.d");

    writeln("Running permissive visitor:");
    mod.accept(new FuncFinderPermissiveVisitor());

    writeln("Running strict visitor (should assert):");
    try
    {
        mod.accept(new FuncFinderStrictVisitor());
        assert(false, "Strict visitor unexpectedly succeeded");
    }
    catch (AssertError)
    {
        writeln("strict visitor triggered assertion on unsupported node");
    }
}
