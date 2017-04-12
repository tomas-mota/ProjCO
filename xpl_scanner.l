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

WHITESPACE             [ \t\n\r]+
HEX                    0x[A-Za-z0-9]+

%x X_STRING X_LCOMMENT X_COMMENT X
%%

"//".*$                ; /* ignore comments */

"/*"                   yy_push_state(X_COMMENT);

">="                   return tGE; 
"<="                   return tLE; 
"=="                   return tEQ; 
"!="                   return tNE; 
"int"                  return tINTEGER; 
"real"                 return tREAL; 
"string"               return tSTRING; 
"xpl"                  return tMAIN;

"public"               return tPUBLIC;
"use"                  return tUSE;
"null"                 return tNULL;
"next"                 return tNEXT;
"stop"                 return tSTOP;
"return"               return tRETURN;
"procedure"            return tPROCEDURE;
"while"                return tWHILE; 
"sweep"                return tSWEEP; 
"if"                   return tIF; 
"else"                 return tELSE; 
"elsif"                return tELSIF; 
"!"                    return tPRINT; 
"@"                    return tREAD; 

[A-Za-z_][A-Za-z0-9_]* yylval.s = new std::string(yytext); return tIDENTIFIER;

\"                     yy_push_state(X_STRING); yylval.s = new std::string("");
<X_STRING>\"|\0        yy_pop_state(); return tSTRING;
<X_STRING>\\\"         *yylval.s += yytext + 1;
<X_STRING>[\t\n\r]+   ;
<X_STRING>.            *yylval.s += yytext;

<X_COMMENT>"/*"        yy_push_state(X_COMMENT); 
<X_COMMENT>"*/"        yy_pop_state();
<X_COMMENT>.|\n        ;

0|[1-9][0-9]*         yylval.i = strtol(yytext, nullptr, 10); return tINTEGER;
HEX                    yylval.i = strtol(yytext, nullptr, 16); return tINTEGER;

[0-9]*

[-()<>=+*/%;{}.]       return *yytext;

WHITESPACE             ; /* ignore whitespace */

.                      yyerror("Unknown character");










%%
// Very, very dirty hack: flex is a mess generating C++ scanners.
int xpl_scanner::yywrap() { return 1; }
