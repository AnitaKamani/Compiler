/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Copyright (C) 1998-2018  Gerwin Klein <lsf@jflex.de>                    *
 * All rights reserved.                                                    *
 *                                                                         *
 * License: BSD                                                            *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* Java 1.2 language lexer specification */

/* Use together with unicode.flex for Unicode preprocesssing */
/* and java12.cup for a Java 1.2 parser                      */

/* Note that this lexer specification is not tuned for speed.
   It is in fact quite slow on integer and floating point literals, 
   because the input is read twice and the methods used to parse
   the numbers are not very fast. 
   For a production quality application (e.g. a Java compiler) 
   this could be optimized */


import java_cup.runtime.*;

%%

%public
%class Scanner
%implements sym

%unicode

%line
%column

%cup
%cupdebug

%{
  StringBuilder string = new StringBuilder();
  
  private Symbol symbol(int type) {
    return new JavaSymbol(type, yyline+1, yycolumn+1);
  }

  private Symbol symbol(int type, Object value) {
    return new JavaSymbol(type, yyline+1, yycolumn+1, value);
  }

  /** 
   * assumes correct representation of a long value for 
   * specified radix in scanner buffer from <code>start</code> 
   * to <code>end</code> 
   */
  private long parseLong(int start, int end, int radix) {
    long result = 0;
    long digit;

    for (int i = start; i < end; i++) {
      digit  = Character.digit(yycharat(i),radix);
      result*= radix;
      result+= digit;
    }

    return result;
  }
%}

/* main character classes */
LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]

WhiteSpace = {LineTerminator} | [ \t\f]

/* comments */
Comment = {TraditionalComment} | {EndOfLineComment} | 
          {DocumentationComment}

TraditionalComment = "/*" [^*] ~"*/" | "/*" "*"+ "/"
EndOfLineComment = "//" {InputCharacter}* {LineTerminator}?
DocumentationComment = "/*" "*"+ [^/*] ~"*/"

/* identifiers */
Identifier = [:jletter:][:jletterdigit:]*

/* integer literals */
DecIntegerLiteral = 0 | [1-9][0-9]*
DecLongLiteral    = {DecIntegerLiteral} [lL]

HexIntegerLiteral = 0 [xX] 0* {HexDigit} {1,8}
HexLongLiteral    = 0 [xX] 0* {HexDigit} {1,16} [lL]
HexDigit          = [0-9a-fA-F]

OctIntegerLiteral = 0+ [1-3]? {OctDigit} {1,15}
OctLongLiteral    = 0+ 1? {OctDigit} {1,21} [lL]
OctDigit          = [0-7]
    
/* floating point literals */        
FloatLiteral  = ({FLit1}|{FLit2}|{FLit3}) {Exponent}? [fF]
DoubleLiteral = ({FLit1}|{FLit2}|{FLit3}) {Exponent}?

FLit1    = [0-9]+ \. [0-9]* 
FLit2    = \. [0-9]+ 
FLit3    = [0-9]+ 
Exponent = [eE] [+-]? [0-9]+

/* string and character literals */
StringCharacter = [^\r\n\"\\]
SingleCharacter = [^\r\n\'\\]

%state STRING, CHARLITERAL

%%

<YYINITIAL> {

  /* keywords */
 [aA][bB][sS][tT][rR][aA][cC][tT]                  { return symbol(ABSTRACT); }
 [bB][oO][oO][lL][eE][aA][nN]                      { return symbol(BOOLEAN); }
 [bB][rR][eE][aA][kK]                              { return symbol(BREAK); }
 [bB][yY][tT][eE]                                  { return symbol(BYTE); }
 [cC][aA][sS][eE]                                  { return symbol(CASE); }
 [cC][aA][tT][cC][hH]                              { return symbol(CATCH); }
 [cC][hH][aA][rR]                                  { return symbol(CHAR); }
 [cC][lL][aA][sS][sS]                              { return symbol(CLASS); }
 [cC][oO][nN][sS][tT]                              { return symbol(CONST); }
 [cC][oO][nN][tT][iI][nN][uU][eE]                  { return symbol(CONTINUE); }
 [dD][oO]                                          { return symbol(DO); }
 [dD][oO][uU][bB][lL][eE]                          { return symbol(DOUBLE); }
 [eE][lL][sS][eE]                                  { return symbol(ELSE); }
 [eE][xX][tT][eE][nN][dD][sS]                      { return symbol(EXTENDS); }
 [fF][iI][nN][aA][lL]                              { return symbol(FINAL); }
 [fF][iI][nN][aA][lL][lL][yY]                      { return symbol(FINALLY); }
 [fF][lL][oO][aA][tT]                              { return symbol(FLOAT); }
 [fF][oO][rR]                                      { return symbol(FOR); }
 [dD][eE][fF][aA][uU][lL][tT]                      { return symbol(DEFAULT); }
 [iI][mM][pP][lL][eE][mM][eE][nN][tT][sS]          { return symbol(IMPLEMENTS); }
 [iI][mM][pP][oO][rR][tT]                          { return symbol(IMPORT); }
 [iI][nN][sS][tT][aA][nN][cC][eE][oO][fF]          { return symbol(INSTANCEOF); }
 [iI][nN][tT]                                      { return symbol(INT); }
 [iI][nN][tT][eE][rR][fF][aA][cC][eE]              { return symbol(INTERFACE); }
 [lL][oO][nN][gG]                                  { return symbol(LONG); }
 [nN][aA][tT][iI][vV][eE]                          { return symbol(NATIVE); }
 [nN][eE][wW]                                      { return symbol(NEW); }
 [gG][oO][tT][oO]                                  { return symbol(GOTO); }
 [iI][fF]                                          { return symbol(IF); }
 [pP][uU][bB][lL][iI][cC]                          { return symbol(PUBLIC); }
 [sS][hH][oO][rR][tT]                              { return symbol(SHORT); }
 [sS][uU][pP][eE][rR]                              { return symbol(SUPER); }
 [sS][wW][iI][tT][cC][hH]                          { return symbol(SWITCH); }
 [sS][yY][nN][cC][hH][rR][oO][nN][iI][zZ][eE][dD]  { return symbol(SYNCHRONIZED); }
 [pP][aA][cC][kK][aA][gG][eE]                      { return symbol(PACKAGE); }
 [pP][rR][iI][vV][aA][tT][eE]                      { return symbol(PRIVATE); }
 [pP][rR][oO][tT][eE][cC][tT][eE][dD]              { return symbol(PROTECTED); }
 [tT][rR][aA][nN][sS][iI][eE][nN][tT]              { return symbol(TRANSIENT); }
 [rR][eE][tT][uU][rR][nN]                          { return symbol(RETURN); }
 [vV][oO][iI][dD]                                  { return symbol(VOID); }
 [sS][tT][aA][tT][iI][cC]                          { return symbol(STATIC); }
 [wW][hH][iI][lL][eE]                              { return symbol(WHILE); }
 [tT][hH][iI][sS]                                  { return symbol(THIS); }
 [tT][hH][rR][oO][wW]                              { return symbol(THROW); }
 [tT][hH][rR][oO][wW][sS]                          { return symbol(THROWS); }
 [tT][rR][yY]                                      { return symbol(TRY); }
 [vV][oO][lL][aA][tT][iI][lL][eE]                  { return symbol(VOLATILE); }
 [sS][tT][rR][iI][cC][tT][fF][pP]                  { return symbol(STRICTFP); }
 [hH][eE][lL][lL][oO]                              { return symbol(HELLO); }
 [nN][iI][cC][eE]                                  { return symbol(NICE); }
 [wW][hH][eE][rR][eE]                              { return symbol(WHERE); }
  
  /* boolean literals */
 [tT][rR][uU][eE]                                  { return symbol(BOOLEAN_LITERAL, true); }
 [fF][aA][lL][sS][eE]                              { return symbol(BOOLEAN_LITERAL, false); }

  
  
  /* null literal */
 [nN][uU][lL][lL]                                  { return symbol(NULL_LITERAL); }
  
  
  /* separators */
  "("                            { return symbol(LPAREN); }
  ")"                            { return symbol(RPAREN); }
  "{"                            { return symbol(LBRACE); }
  "}"                            { return symbol(RBRACE); }
  "["                            { return symbol(LBRACK); }
  "]"                            { return symbol(RBRACK); }
  ";"                            { return symbol(SEMICOLON); }
  ","                            { return symbol(COMMA); }
  "."                            { return symbol(DOT); }
  
  /* operators */
  "="                            { return symbol(EQ); }
  ">"                            { return symbol(GT); }
  "<"                            { return symbol(LT); }
  "!"                            { return symbol(NOT); }
  "~"                            { return symbol(COMP); }
  "?"                            { return symbol(QUESTION); }
  ":"                            { return symbol(COLON); }
  "=="                           { return symbol(EQEQ); }
  "<="                           { return symbol(LTEQ); }
  ">="                           { return symbol(GTEQ); }
  "!="                           { return symbol(NOTEQ); }
  "&&"                           { return symbol(ANDAND); }
  "||"                           { return symbol(OROR); }
  "++"                           { return symbol(PLUSPLUS); }
  "--"                           { return symbol(MINUSMINUS); }
  "+"                            { return symbol(PLUS); }
  "-"                            { return symbol(MINUS); }
  "*"                            { return symbol(MULT); }
  "/"                            { return symbol(DIV); }
  "&"                            { return symbol(AND); }
  "|"                            { return symbol(OR); }
  "^"                            { return symbol(XOR); }
  "%"                            { return symbol(MOD); }
  "<<"                           { return symbol(LSHIFT); }
  ">>"                           { return symbol(RSHIFT); }
  ">>>"                          { return symbol(URSHIFT); }
  "+="                           { return symbol(PLUSEQ); }
  "-="                           { return symbol(MINUSEQ); }
  "*="                           { return symbol(MULTEQ); }
  "/="                           { return symbol(DIVEQ); }
  "&="                           { return symbol(ANDEQ); }
  "|="                           { return symbol(OREQ); }
  "^="                           { return symbol(XOREQ); }
  "%="                           { return symbol(MODEQ); }
  "<<="                          { return symbol(LSHIFTEQ); }
  ">>="                          { return symbol(RSHIFTEQ); }
  ">>>="                         { return symbol(URSHIFTEQ); }
  
  /* string literal */
  \"                             { yybegin(STRING); string.setLength(0); }

  /* character literal */
  \'                             { yybegin(CHARLITERAL); }

  /* numeric literals */

  /* This is matched together with the minus, because the number is too big to 
     be represented by a positive integer. */
  "-2147483648"                  { return symbol(INTEGER_LITERAL, Integer.valueOf(Integer.MIN_VALUE)); }
  
  {DecIntegerLiteral}            { return symbol(INTEGER_LITERAL, Integer.valueOf(yytext())); }
  {DecLongLiteral}               { return symbol(INTEGER_LITERAL, new Long(yytext().substring(0,yylength()-1))); }
  
  {HexIntegerLiteral}            { return symbol(INTEGER_LITERAL, Integer.valueOf((int) parseLong(2, yylength(), 16))); }
  {HexLongLiteral}               { return symbol(INTEGER_LITERAL, new Long(parseLong(2, yylength()-1, 16))); }
 
  {OctIntegerLiteral}            { return symbol(INTEGER_LITERAL, Integer.valueOf((int) parseLong(0, yylength(), 8))); }
  {OctLongLiteral}               { return symbol(INTEGER_LITERAL, new Long(parseLong(0, yylength()-1, 8))); }
  
  {FloatLiteral}                 { return symbol(FLOATING_POINT_LITERAL, new Float(yytext().substring(0,yylength()-1))); }
  {DoubleLiteral}                { return symbol(FLOATING_POINT_LITERAL, new Double(yytext())); }
  {DoubleLiteral}[dD]            { return symbol(FLOATING_POINT_LITERAL, new Double(yytext().substring(0,yylength()-1))); }
  
  /* comments */
  {Comment}                      { return symbol(CM); }

  /* whitespace */
  {WhiteSpace}                   { return symbol(WS); }

  /* identifiers */ 
  {Identifier}                   { return symbol(IDENTIFIER, yytext()); }  
}

<STRING> {
  \"                             { yybegin(YYINITIAL); return symbol(STRING_LITERAL, string.toString()); }
  
  {StringCharacter}+             { string.append( yytext() ); }
  
  /* escape sequences */
  "\\b"                          { string.append( '\b' ); }
  "\\t"                          { string.append( '\t' ); }
  "\\n"                          { string.append( '\n' ); }
  "\\f"                          { string.append( '\f' ); }
  "\\r"                          { string.append( '\r' ); }
  "\\\""                         { string.append( '\"' ); }
  "\\'"                          { string.append( '\'' ); }
  "\\\\"                         { string.append( '\\' ); }
  \\[0-3]?{OctDigit}?{OctDigit}  { char val = (char) Integer.parseInt(yytext().substring(1),8);
                        				   string.append( val ); }
  
  /* error cases */
  \\.                            { throw new RuntimeException("Illegal escape sequence \""+yytext()+"\""); }
  {LineTerminator}               { throw new RuntimeException("Unterminated string at end of line"); }
}

<CHARLITERAL> {
  {SingleCharacter}\'            { yybegin(YYINITIAL); return symbol(CHARACTER_LITERAL, yytext().charAt(0)); }
  
  /* escape sequences */
  "\\b"\'                        { yybegin(YYINITIAL); return symbol(CHARACTER_LITERAL, '\b');}
  "\\t"\'                        { yybegin(YYINITIAL); return symbol(CHARACTER_LITERAL, '\t');}
  "\\n"\'                        { yybegin(YYINITIAL); return symbol(CHARACTER_LITERAL, '\n');}
  "\\f"\'                        { yybegin(YYINITIAL); return symbol(CHARACTER_LITERAL, '\f');}
  "\\r"\'                        { yybegin(YYINITIAL); return symbol(CHARACTER_LITERAL, '\r');}
  "\\\""\'                       { yybegin(YYINITIAL); return symbol(CHARACTER_LITERAL, '\"');}
  "\\'"\'                        { yybegin(YYINITIAL); return symbol(CHARACTER_LITERAL, '\'');}
  "\\\\"\'                       { yybegin(YYINITIAL); return symbol(CHARACTER_LITERAL, '\\'); }
  \\[0-3]?{OctDigit}?{OctDigit}\' { yybegin(YYINITIAL); 
			                              int val = Integer.parseInt(yytext().substring(1,yylength()-1),8);
			                            return symbol(CHARACTER_LITERAL, (char)val); }
  
  /* error cases */
  \\.                            { throw new RuntimeException("Illegal escape sequence \""+yytext()+"\""); }
  {LineTerminator}               { throw new RuntimeException("Unterminated character literal at end of line"); }
}

/* error fallback */
[^]                              { throw new RuntimeException("Illegal character \""+yytext()+
                                                              "\" at line "+yyline+", column "+yycolumn); }
<<EOF>>                          { return symbol(EOF); }