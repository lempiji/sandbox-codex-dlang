/**
 * This example parses `source/app.d` using DMD's frontend and then
 * walks the resulting AST with a `PrintVisitor` (derived from
 * `ParseTimeVisitor`) to print symbol and statement information.
 */

import std.stdio;
import std.string : fromStringz;

import dmd.frontend;
import dmd.astcodegen;
import dmd.visitor;
alias AST = ASTCodegen;

private AST.Module initAndParse(string sourcePath)
{
    // Initialize the DMD frontend runtime
    initDMD();
    // Parse the requested source file and obtain its AST
    auto result = parseModule(sourcePath);
    // Return the top-level module node
    return result.module_;
}

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
    // Parse this file using DMD's frontend
    auto mod = initAndParse("source/app.d");
    // Create the visitor that will print symbol and statement info
    auto visitor = new PrintVisitor();
    // Walk the AST with our visitor
    traverse(mod, visitor);
}
