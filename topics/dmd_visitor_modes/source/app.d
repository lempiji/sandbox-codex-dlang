import std.stdio;
import std.string : fromStringz;
import core.exception : AssertError;

import dmd.frontend;
import dmd.dmodule;
import dmd.astbase : ASTBase;
import dmd.location : Loc;
import dmd.identifier : Identifier;
import dmd.astenums : STC, TY;
import dmd.visitor.permissive;
import dmd.visitor.strict;

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
    initDMD();
    // Manually construct a small AST: module with a function and a variable
    auto mod = new ASTBase.Module("example.d", Identifier.idPool("example"), 0, 0);
    auto members = new ASTBase.Dsymbols();
    mod.members = members;

    auto func = new ASTBase.FuncDeclaration(Loc.initial, Loc.initial,
        Identifier.idPool("foo"), STC.none, null);
    members.push(func);

    auto t = new ASTBase.TypeBasic(TY.Tint32);
    auto var = new ASTBase.VarDeclaration(Loc.initial, t,
        Identifier.idPool("bar"), null);
    members.push(var);

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
