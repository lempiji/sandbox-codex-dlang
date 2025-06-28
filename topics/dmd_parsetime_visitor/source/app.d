/**
 * This example parses `source/app.d` using DMD's frontend and then
 * walks the resulting AST with a `PrintVisitor` (derived from
 * `ParseTimeVisitor`) to print symbol and statement information.
 */

import std.stdio;
import std.string : fromStringz;
import dmd.astbase : ASTBase;
import dmd.parse : Parser;
import dmd.errorsink : ErrorSinkStderr;
import dmd.globals;
import dmd.id;
import dmd.identifier;
import dmd.target;
import std.file : readText;
import dmd.visitor.parsetime;
alias AST = ASTBase;

private AST.Module initAndParse(string fname)
{
    Id.initialize();
    global._init();
    target.os = Target.OS.linux;
    target.isX86_64 = (size_t.sizeof == 8);
    global.params.useUnitTests = true;
    AST.Type._init();

    auto id = Identifier.idPool(fname);
    auto mod = new AST.Module(&(fname.dup)[0], id, false, false);
    auto input = readText(fname) ~ "\0";

    scope p = new Parser!AST(mod, input, false, new ErrorSinkStderr(), null, false);
    p.nextToken();
    mod.members = p.parseModule();

    return mod;
}

extern(C++) class PrintVisitor : ParseTimeVisitor!AST
{
    alias visit = ParseTimeVisitor!AST.visit;

    override void visit(AST.Dsymbol s)
    {
        auto name = s.ident ? s.ident.toString() : "__anonymous";
        writeln("Dsymbol: ", fromStringz(s.kind()), " ", name);
    }

    override void visit(AST.Statement st)
    {
        writeln(" Statement at ", fromStringz(st.loc.toChars()));
    }
}

void traverse(AST.Dsymbol s, PrintVisitor v)
{
    s.accept(v);
    auto sc = cast(AST.ScopeDsymbol)s;
    if (sc && sc.members && cast(size_t)sc.members > 2)
        foreach (member; *sc.members)
            traverse(member, v);
}

void main()
{
    // Parse this file using DMD's frontend
    auto mod = initAndParse("source/app.d");
    // Create the visitor that will print symbol and statement info
    auto visitor = new PrintVisitor();
    // Walk the AST with our visitor
    traverse(mod, visitor);
}
