%option c++ yyclass="xpl_scanner" outfile="xpl_scanner.cpp"
%option stack noyywrap yylineno 8bit
%{ 
/* $Id: xpl_scanner.l,v 1.1 2017/02/17 16:02:31 david Exp $ */
// make relevant includes before including the parser's tab file
#include <string>
#include <cdk/ast/sequence_node.h>
#include <cdk/ast/expression_node.h>
#include "xpl_scanner.h"
#include "xpl_parser.tab.h"

// don't change this
#define yyerror LexerError
%}

%x X_STRING X_COMMENT X_STR_SPECIAL
%%

"//".*$                ; /* ignore comments */

"/*"                   yy_push_state(X_COMMENT);

">="                   return tGE; 
"<="                   return tLE; 
"=="                   return tEQ; 
"!="                   return tNE; 
"int"                  return tINT;
"real"                 return tREAL; 
"string"               return tSTRING; 
"!!"                   return tPRINTLN;

"public"               return tPUBLIC;
"use"                  return tUSE;
"null"                 return tNULL;
"next"                 return tNEXT;
"stop"                 return tSTOP;
"return"               return tRETURN;
"procedure"            return tPROC;
"while"                return tWHILE; 
"sweep"                return tSWEEP; 
"if"                   return tIF; 
"else"                 return tELSE; 
"elsif"                return tELSIF; 

[A-Za-z_][A-Za-z0-9_]* {yylval.s = new std::string(yytext); return tIDENTIFIER;}

\"                     yy_push_state(X_STRING); yylval.s = new std::string("");
<X_STRING>\"           yy_pop_state(); return tLITSTR;
<X_STRING>\\\"         *yylval.s += yytext + 1;
<X_STRING>.            *yylval.s += yytext;         /*special characters will be dealt with on postfix */



0x[A-Za-z0-9]+                          {yylval.i = strtol(yytext, nullptr, 16); return tLITINT;}
[1-9][0-9]*                             {yylval.i = strtol(yytext, nullptr, 10); return tLITINT;}
0                                       {yylval.i = strtol(yytext, nullptr, 10); return tLITINT;}
[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?       {yylval.d = strtod(yytext, nullptr); return tLITREAL;}

<X_COMMENT>"/*"        yy_push_state(X_COMMENT); 
<X_COMMENT>"*/"        yy_pop_state();
<X_COMMENT>.|\n        ;

[-()<>=+*/%;{}.,?@\[\]|&!:]     return *yytext;

[ \t\n\r]+             ; /* ignore whitespace */

.                      yyerror("Unknown character");



%%
// Very, very dirty hack: flex is a mess generating C++ scanners.
int xpl_scanner::yywrap() { return 1; }
