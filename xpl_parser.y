%{
// $Id: xpl_parser.y,v 1.1 2017/02/17 16:02:31 david Exp $
//-- don't change *any* of these: if you do, you'll break the compiler.
#include <cdk/compiler.h>
#include "ast/all.h"
#define LINE       compiler->scanner()->lineno()
#define yylex()    compiler->scanner()->scan()
#define yyerror(s) compiler->scanner()->error(s)
#define YYPARSE_PARAM_TYPE std::shared_ptr<cdk::compiler>
#define YYPARSE_PARAM      compiler
//-- don't change *any* of these --- END!
%}

%union {
  int                   i;	/* integer value */
  float                 r;
  bool                  b;
  basic_type           *t;
  std::string          *s;	/* symbol name or string literal */
  cdk::basic_node      *node;	/* node pointer */
  cdk::sequence_node   *sequence;
  cdk::expression_node *expression; /* expression nodes */
  cdk::lvalue_node     *lvalue;
};

%token <b> tPUBLIC tUSE tPROCEDURE
%token <r> tLITREAL
%token <i> tLITINT
%token <s> tIDENTIFIER tLITSTR
%token tWHILE tIF tPRINT tREAD tEND tINT tREAL tMAIN tPUBLIC tUSE tNULL tNEXT tSTOP tRETURN tSWEEP tELSIF 
%token tINTEGER tSTRING tREAL

%nonassoc tIFX
%nonassoc tELSE

%right '='
%left '|'
%left '&'
%nonassoc '~'
%left tEQ tNE
%left tGE tLE '>' '<'
%left '+' '-'
%left '*' '/' '%'
%nonassoc tUNARY '?'
%nonassoc '(' ')' '[' ']'

%type <node> stmt program var sweep
%type <sequence> list
%type <expression> expr
%type <lvalue> lval
%type <t> type ptr

%{
//-- The rules below will be included in yyparse, the main parsing function.
%}
%%

program	: list tMAIN //-- { compiler->ast(new cdk::sequence_node(LINE)); }
	      ;

list : stmt	     { $$ = new cdk::sequence_node(LINE, $1); }
	   | list stmt { $$ = new cdk::sequence_node(LINE, $2, $1); }
	   ;

stmt : expr ';'                         { $$ = new xpl::evaluation_node(LINE, $1); }
 	   | expr tPRINT                      { $$ = new xpl::print_node(LINE, false, $1); }
 	   | expr tPRINT tPRINT               { $$ = new xpl::print_node(LINE, true, $1); }
     | tREAD lval ';'                   { $$ = new xpl::read_node(LINE); }
     | tWHILE '(' expr ')' stmt         { $$ = new xpl::while_node(LINE, $3, $5); }
     | tIF '(' expr ')' stmt %prec tIFX { $$ = new xpl::if_node(LINE, $3, $5); }
     | tIF '(' expr ')' stmt tELSE stmt { $$ = new xpl::if_else_node(LINE, $3, $5, $7); }
     | '{' list '}'                     { $$ = $2; }
     | var                              { $$ = $1; }
     ;


expr : tLITINT                 { $$ = new cdk::integer_node(LINE, $1); }
	   | tLITSTR                 { $$ = new cdk::string_node(LINE, $1); }
     | '-' expr %prec tUNARY   { $$ = new cdk::neg_node(LINE, $2); }
     | '+' expr %prec tUNARY   { $$ = new cdk::neg_node(LINE, $2); }    //a resolver
     | expr '+' expr	         { $$ = new cdk::add_node(LINE, $1, $3); }
     | expr '-' expr	         { $$ = new cdk::sub_node(LINE, $1, $3); }
     | expr '*' expr	         { $$ = new cdk::mul_node(LINE, $1, $3); }
     | expr '/' expr	         { $$ = new cdk::div_node(LINE, $1, $3); }
     | expr '%' expr	         { $$ = new cdk::mod_node(LINE, $1, $3); }
     | expr '<' expr	         { $$ = new cdk::lt_node(LINE, $1, $3); }
     | expr '>' expr	         { $$ = new cdk::gt_node(LINE, $1, $3); }
     | expr tGE expr	         { $$ = new cdk::ge_node(LINE, $1, $3); }
     | expr tLE expr           { $$ = new cdk::le_node(LINE, $1, $3); }
     | expr tNE expr	         { $$ = new cdk::ne_node(LINE, $1, $3); }
     | expr tEQ expr	         { $$ = new cdk::eq_node(LINE, $1, $3); }
     | expr '&' expr	         { $$ = new cdk::and_node(LINE, $1, $3); }
     | expr '|' expr	         { $$ = new cdk::or_node(LINE, $1, $3); }
     | '~' expr	               { $$ = new cdk::not_node(LINE, $2); }
     | '(' expr ')'            { $$ = $2; }
     | '?' lval                { $$ = new xpl::address_node(LINE, $2); }
     | lval                    { $$ = new cdk::rvalue_node(LINE, $1); }  //FIXME
     | lval '=' expr           { $$ = new cdk::assignment_node(LINE, $1, $3); }
     //| lval '[' expr/rval ']'  { $$ = new cdk::address_node(LINE, $1, $3); }      fix this (address node)
     ;

lval : tIDENTIFIER             { $$ = new cdk::identifier_node(LINE, $1); }
     ;

type : tINT								{ $$ = new basic_type(4, basic_type::TYPE_INT); } 			
		 | tREAL							{ $$ = new basic_type(8, basic_type::TYPE_DOUBLE); }					
		 | tSTRING						{ $$ = new basic_type(4, basic_type::TYPE_STRING); }
		 | ptr  							{ $$ = $1; }  //tenho de adicionar nested pointer
     ;

ptr  : '[' type ']'       { $$ = new basic_type(4, basic_type::TYPE_POINTER);}
     ;

var  : tPUBLIC type tIDENTIFIER '=' expr { $$ = new xpl::vardeclaration_node(LINE, true, false, $2, $3, $5);} 			
	   | tUSE type tIDENTIFIER '=' expr    { $$ = new xpl::vardeclaration_node(LINE, false, true, $2, $3, $5);}
	   | type tIDENTIFIER '=' expr         { $$ = new xpl::vardeclaration_node(LINE, false, false, $1, $2, $4);}
	   | type tIDENTIFIER                  { $$ = new xpl::vardeclaration_node(LINE, false, false, $1, $2, nullptr);}
     ; 

vars : var
     | var ',' vars
     ;


%%
