import std.stdio;

import dmd.astbase : ASTBase;
import dmd.parse : Parser;
import dmd.errorsink : ErrorSinkStderr;
import dmd.globals;
import dmd.id;
import dmd.identifier;
import dmd.target;
import std.file : readText;
import dmd.visitor.transitive;

extern(C++) class DeclCounterVisitor(AST) : ParseTimeTransitiveVisitor!AST
{
    alias visit = ParseTimeTransitiveVisitor!AST.visit;
    size_t declCount = 0;

    override void visit(AST.VarDeclaration d)
    {
        ++declCount;
        super.visit(d); // automatically visits children
    }

    override void visit(AST.FuncDeclaration d)
    {
        ++declCount;
        super.visit(d);
    }
}

void main()
{
    string fname = "source/app.d";
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

    scope v = new DeclCounterVisitor!ASTBase();
    mod.accept(v);

    writeln("Total declarations: ", v.declCount);
}
