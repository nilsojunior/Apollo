import java_cup.runtime.*;

%%
%class PdfView
%unicode
%cup
%line
%column

%{
    private Symbol symbol(int type) {
        return new Symbol(type, yyline, yycolumn);
    }
    private Symbol symbol(int type, Object value) {
        return new Symbol(type, yyline, yycolumn, value);
    }

    private StringBuilder contentBuffer = new StringBuilder();
    private int braceDepth = 0;
%}

LineTerminator = \r|\n|\r\n
SingleLineComment = --.+
COMMENT = {SingleLineComment}
WHITESPACE = {LineTerminator} | [ \t\f]
LANG = [\w]+

%state BRACE_CONTENT

%%

<YYINITIAL> {
    "TL"                          { return symbol(sym.TL); }
    "P"                           { return symbol(sym.P); }
    "AU"                          { return symbol(sym.AU); }
    "AUI"                         { return symbol(sym.AUI); }
    "DATE"                        { return symbol(sym.DATE); }
    "NH"                          { return symbol(sym.NH); }
    "NH 1"                        { return symbol(sym.NH_1); }
    "NH 2"                        { return symbol(sym.NH_2); }
    "H"                           { return symbol(sym.H); }
    "AB"                          { return symbol(sym.AB); }
    "IP"                          { return symbol(sym.IP); }
    "BP"                          { return symbol(sym.BP); }
    "BP 4"                        { return symbol(sym.BP_4); }
    "CB " {LANG}                  { return symbol(sym.CB, yytext().substring(3)); } // Only return the language

    "{"                           { 
        contentBuffer.setLength(0);
        braceDepth = 1;
        yybegin(BRACE_CONTENT);
    }

    {WHITESPACE}                   { /* Ignore */ }
    {COMMENT}                      { /* Ignore */ }

    // Fallback
    . { 
        System.err.println("Invalid character at line " + yyline + " column " + yycolumn + ": '" + yytext() + "'");
    }
}

<BRACE_CONTENT> {
    "{"                           { 
        braceDepth++;
        contentBuffer.append(yytext());
    }

    "}"                           { 
        braceDepth--;
        if (braceDepth == 0) {
            // Found matching closing brace
            String content = contentBuffer.toString().trim();
            // System.out.println(content);
            yybegin(YYINITIAL);
            return symbol(sym.CONTENT, content);
        } else {
            contentBuffer.append(yytext());
        }
    }

    [^{}]+                        { 
            // String matched = yytext();
            // System.err.println("Captured: '" + matched + "'");
            contentBuffer.append(yytext());
    }
}
