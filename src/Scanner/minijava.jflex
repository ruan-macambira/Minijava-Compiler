/**
 * JFlex specification for lexical analysis of a simple demo language.
 * Change this into the scanner for your implementation of MiniJava.
 *
 * CSE 401/M501/P501 18sp
 */


package Scanner;

import java_cup.runtime.Symbol;
import java_cup.runtime.ComplexSymbolFactory;
import java_cup.runtime.ComplexSymbolFactory.ComplexSymbol;
import java_cup.runtime.ComplexSymbolFactory.Location;
import Parser.sym;

%%
%public
%final
%class scanner
%unicode
%cup
%line
%column

/* The following code block is copied literally into the generated scanner
 * class. You can use this to define methods and/or declare fields of the
 * scanner class, which the lexical actions may also reference. Most likely,
 * you will only need to tweak what's already provided below.
 *
 * We use CUP's ComplexSymbolFactory and its associated ComplexSymbol class
 * that tracks the source location of each scanned symbol.
 */
%{  
  /** The CUP symbol factory, typically shared with parser. */
  private ComplexSymbolFactory symbolFactory = new ComplexSymbolFactory();

  /** Initialize scanner with input stream and a shared symbol factory. */
  public scanner(java.io.Reader in, ComplexSymbolFactory sf) {
    this(in);
    this.symbolFactory = sf;
  }

  /**
   * Construct a symbol with a given lexical token, a given
   * user-controlled datum, and the matched source location.
   *
   * @param code     identifier of the lexical token (i.e., sym.<TOKEN>)
   * @param value    user-controlled datum to associate with this symbol
   * @effects        constructs new ComplexSymbol via this.symbolFactory
   * @return         a fresh symbol storing the above-desribed information
   */
  private Symbol symbol(int code, Object value) {
    // Calculate symbol location
    int yylen = yylength();
    Location left = new Location(yyline + 1, yycolumn + 1, yychar);
    Location right = new Location(yyline + 1, yycolumn + yylen, yychar + yylen);
    // Calculate symbol name
    int max_code = sym.terminalNames.length;
    String name = code < max_code ? sym.terminalNames[code] : "<UNKNOWN(" + yytext() + ")>";
    return this.symbolFactory.newSymbol(name, code, left, right, value);
  }

  /**
   * Construct a symbol with a given lexical token and matched source
   * location, leaving the user-controlled value field uninitialized.
   *
   * @param code     identifier of the lexical token (i.e., sym.<TOKEN>)
   * @effects        constructs new ComplexSymbol via this.symbolFactory
   * @return         a fresh symbol storing the above-desribed information
   */
  private Symbol symbol(int code) {
    // Calculate symbol location
    int yylen = yylength();
    Location left = new Location(yyline + 1, yycolumn + 1, yychar);
    Location right = new Location(yyline + 1, yycolumn + yylen, yychar + yylen);
    // Calculate symbol name
    int max_code = sym.terminalNames.length;
    String name = code < max_code ? sym.terminalNames[code] : "<UNKNOWN(" + yytext() + ")>";
    return this.symbolFactory.newSymbol(name, code, left, right);
  }

  /**
   * Convert the symbol generated by this scanner into a string.
   *
   * This method is useful to include information in the string representation
   * in addition to the plain CUP name for a lexical token.
   *
   * @param symbol   symbol instance generated by this scanner
   * @return         string representation of the symbol
   */
   public String symbolToString(Symbol s) {
     // All symbols generated by this class are ComplexSymbol instances
     ComplexSymbol cs = (ComplexSymbol)s; 
     if (cs.sym == sym.IDENTIFIER)
     {
       return "ID(" + (String)cs.value + ")";
     }
     else if (cs.sym == sym.INTEGER)
     {
       return "INTEGER(" + String.valueOf(cs.value) + ")";
     }
     else if (cs.sym == sym.error)
     {
       return "<UNEXPECTED(" + (String)cs.value + ")>";
     }
     else
     {
       return cs.getName();
     }
   }
%}

/* Helper definitions */
letter = [a-zA-Z]
digit = [0-9]
eol = [\r\n]
white = {eol}|[ \t]

%%

/* Token definitions */

/* reserved words (first so that they take precedence over identifiers) */
"display" { return symbol(sym.DISPLAY); }
"class" { return symbol(sym.CLASS); }
"static void main" { return symbol(sym.MAIN); }
"String" { return symbol(sym.STRING); }
"System.out.println" { return symbol(sym.SYSO); }
"return" { return symbol(sym.RETURN); }
"if" { return symbol(sym.IF); }
"else" { return symbol(sym.ELSE); }
"while" { return symbol(sym.WHILE); }
"new" { return symbol(sym.NEW); }
"this" { return symbol(sym.THIS); }
"public" { return symbol(sym.PUBLIC); }
"int" { return symbol(sym.INT); }
"boolean" { return symbol(sym.BOOLEAN); }

/* operators */
"+" { return symbol(sym.PLUS); }
"-" { return symbol(sym.MINUS); }
"*" { return symbol(sym.MULTI); }
"=" { return symbol(sym.BECOMES); }
"&&" { return symbol(sym.AND); }
"!" { return symbol(sym.NOT); }
"<" { return symbol(sym.LTE); }

/* delimiters */
"(" { return symbol(sym.LPAREN); }
")" { return symbol(sym.RPAREN); }
"[" { return symbol(sym.LBRACK); }
"]" { return symbol(sym.RBRACK); }
"{" { return symbol(sym.LBRACE); }
"}" { return symbol(sym.RBRACE); }
";" { return symbol(sym.SEMICOLON); }

/* number */
(\+|\-)?0|[1-9]{digit}* {
  return symbol(sym.INTEGER, Integer.parseInt(yytext()));
}

/* identifiers */
{letter} ({letter}|{digit}|_)* {
  return symbol(sym.IDENTIFIER, yytext());
}


/* whitespace */
{white}+ { /* ignore whitespace */ }

/* beyond-of-scope handling */
"."{digit}* {
    System.err.printf("%nLine %d, Column %d", yyline+1,yycolumn+1);
    System.err.printf("%nWarning:Minijava does not support floating-point numbers.%n");
}

"\""[^"\"".]"\"" {
  System.err.printf("%nLine %d, Column %d", yyline+1,yycolumn+1);
  System.err.printf("%nWarning:Minijava does not support Strings.%n");
}

/* lexical errors (last so other matches take precedence) */
. {
    System.err.printf(
      "%nUnexpected character '%s' on line %d at column %d of input.%n",
      yytext(), yyline + 1, yycolumn + 1
    );
    return symbol(sym.error, yytext());
  }

<<EOF>> { return symbol(sym.EOF); }
