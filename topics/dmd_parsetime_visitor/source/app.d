import std.stdio;
import std.string : fromStringz;

import dmd.frontend;
import dmd.astcodegen;
import dmd.visitor;
alias AST = ASTCodegen;

extern(C++) class PrintVisitor : Visitor
{
    alias visit = Visitor.visit;

    override void visit(AST.Dsymbol s)
    {
        writeln("Dsymbol: ", fromStringz(s.kind()), " ", fromStringz(s.toChars()));
    }

    override void visit(AST.Statement st)
    {
        writeln(" Statement at ", st.loc.toChars());
    }
}

void traverse(AST.Dsymbol s, PrintVisitor v)
{
    s.accept(v);
    auto sc = cast(AST.ScopeDsymbol)s;
    if (sc && sc.members)
        foreach (member; *sc.members)
            traverse(member, v);
}

void main()
{
    initDMD();
    auto result = parseModule("source/app.d");
    auto mod = result.module_;
    auto visitor = new PrintVisitor();
    traverse(mod, visitor);
}
