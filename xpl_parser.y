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
  xpl::block_node      *bl;
  cdk::basic_node      *node;	/* node pointer */
  cdk::sequence_node   *sequence;
  cdk::expression_node *expression; /* expression nodes */
  cdk::lvalue_node     *lvalue;
};

%token <b> tPUBLIC tUSE tPROC
%token <r> tLITREAL
%token <i> tLITINT
%token <s> tIDENTIFIER tLITSTR
%token tWHILE tIF tPRINT tPRINTLN tREAD tEND tINT tREAL tMAIN tPUBLIC tUSE tNULL tNEXT tSTOP tRETURN tSWEEP tELSIF 
%token tINTEGER tSTRING tREAL

%nonassoc tIFX
%nonassoc tELSE

%right '='
%left ','
%left '|'
%left '&'
%nonassoc '~'
%left tEQ tNE
%left tGE tLE '>' '<'
%left '+' '-'
%left '*' '/' '%'
%nonassoc tUNARY '?' '@'
%nonassoc '(' ')' '[' ']'

%type <node> program var decl inst func var iter
%type <sequence> decls vars insts decls exprs vardecls
%type <expression> expr
%type <lvalue> lval
%type <t> type ptr
%type <s> str
%type <bl> block body

%{
//-- The rules below will be included in yyparse, the main parsing function.
%}
%%

program	: decls //-- { compiler->ast(new cdk::sequence_node(LINE)); }
	      ;

decl : var ';'							              { $$ = $1; }
		 | func							                  { $$ = $1; }
		 ;

var  : tPUBLIC type tIDENTIFIER '=' expr { $$ = new xpl::vardeclaration_node(LINE, true, false, $2, $3, $5); } 			
	   | tUSE type tIDENTIFIER '=' expr    { $$ = new xpl::vardeclaration_node(LINE, false, true, $2, $3, $5); }
	   | type tIDENTIFIER '=' expr         { $$ = new xpl::vardeclaration_node(LINE, false, false, $1, $2, $4); }
	   | type tIDENTIFIER                  { $$ = new xpl::vardeclaration_node(LINE, false, false, $1, $2, nullptr); }
     ; 

func : tPROC tIDENTIFIER '(' vars ')'    { $$ = new xpl::fundeclaration_node(LINE, true, false, false, new basic_type(4, basic_type::TYPE_UNSPEC), $2, $4); }
     ;

type : tINT								     { $$ = new basic_type(4, basic_type::TYPE_INT); } 			
		 | tREAL							     { $$ = new basic_type(8, basic_type::TYPE_DOUBLE); }					
		 | tSTRING				         { $$ = new basic_type(4, basic_type::TYPE_STRING); }
		 | ptr  					  	     { $$ = $1; }
     ;

body : block                   { $$ = $1; }
     ;

block : '{' vardecls insts '}'    { $$ = new xpl::block_node(LINE, $2, $3); }
      | '{' vardecls '}'    { $$ = new xpl::block_node(LINE, $2, nullptr); }
      | '{' insts '}'    { $$ = new xpl::block_node(LINE, nullptr, $3); }
      | '{' '}'    { $$ = new xpl::block_node(LINE, nullptr, nullptr); }

inst : expr ';'                         { $$ = new xpl::evaluation_node(LINE, $1); }
 	   | expr tPRINT                      { $$ = new xpl::print_node(LINE, false, $1); }
 	   | expr tPRINTLN                    { $$ = new xpl::print_node(LINE, true, $1); }
     | tNEXT                            { $$ = new xpl::next_node(LINE); } 
     | tSTOP                            { $$ = new xpl::stop_node(LINE); } 
     | tRETURN                          { $$ = new xpl::return_node(LINE); } 
     //| cond                             { $$ = $1; }
     //| iter                             { $$ = $1; }
     | block                            { $$ = $1; }
     ;

iter : tWHILE '(' expr ')' inst                             { $$ = new xpl::while_node(LINE, $3, $5); }
   //| tSWEEP '+' '(' lvalue ':' expr ':' expr ':' expr ')' instr       TO--DO
     ;



/*
cond : tIF '(' expr ')' inst %prec tIFX            { $$ = new xpl::if_node(LINE, $3, $5); }
     | tIF '(' expr ')' inst tELSE inst            { $$ = new xpl::if_else_node(LINE, $3, $5, $7); } 
     | tIF '(' expr ')' inst elsifs tELSE inst     { $$ = new cdk::sequence_node(LINE); }                     //TO-DO


elsifs : elsif	                            { $$ = new cdk::sequence_node(LINE, $1); }                  
	     | elsifs elsif                       { $$ = new cdk::sequence_node(LINE, $2, $1); }
	     ;

elsif  : tELSIF '(' expr ')' inst           { $$ =  }
*/

expr : tLITINT                    { $$ = new cdk::integer_node(LINE, $1); }
	   | str                        { $$ = new cdk::string_node(LINE, $1); }
     | tLITREAL                   { $$ = new cdk::double_node(LINE, $1); }
     | tIDENTIFIER '(' exprs ')'  { $$ = new xpl::funcall_node(LINE, $1, $3); }
     | '-' expr %prec tUNARY      { $$ = new cdk::neg_node(LINE, $2); }
     | expr '+' expr	            { $$ = new cdk::add_node(LINE, $1, $3); }
     | expr '-' expr	            { $$ = new cdk::sub_node(LINE, $1, $3); }
     | expr '*' expr	            { $$ = new cdk::mul_node(LINE, $1, $3); }
     | expr '/' expr	            { $$ = new cdk::div_node(LINE, $1, $3); }
     | expr '%' expr	            { $$ = new cdk::mod_node(LINE, $1, $3); }
     | expr '<' expr	            { $$ = new cdk::lt_node(LINE, $1, $3); }
     | expr '>' expr	            { $$ = new cdk::gt_node(LINE, $1, $3); }
     | expr tGE expr	            { $$ = new cdk::ge_node(LINE, $1, $3); }
     | expr tLE expr              { $$ = new cdk::le_node(LINE, $1, $3); }
     | expr tNE expr	            { $$ = new cdk::ne_node(LINE, $1, $3); }
     | expr tEQ expr	            { $$ = new cdk::eq_node(LINE, $1, $3); }
     | expr '&' expr	            { $$ = new cdk::and_node(LINE, $1, $3); }
     | expr '|' expr	            { $$ = new cdk::or_node(LINE, $1, $3); }
     | '~' expr	                  { $$ = new cdk::not_node(LINE, $2); }
     | '(' expr ')'               { $$ = $2; }
     | '?' lval                   { $$ = new xpl::address_node(LINE, $2); }
     | '@'                        { $$ = new xpl::read_node(LINE); }
     | lval                       { $$ = new cdk::rvalue_node(LINE, $1); }  //FIXME
     | lval '=' expr              { $$ = new cdk::assignment_node(LINE, $1, $3); }
     | '[' tLITINT ']'
   //| lval '[' expr/rval ']'  { $$ = new cdk::address_node(LINE, $1, $3); }      fix this (address node)
     ;

lval : tIDENTIFIER             { $$ = new cdk::identifier_node(LINE, $1); }
     ;

str  : tLITSTR				         { $$ = $1; }
     | str tLITSTR		         { $$ = new std::string(*$1 + *$2); }
     ; 

ptr  : '[' type ']'            { $$ = new basic_type(4, basic_type::TYPE_POINTER);}
     ;

/*
sweep : tSWEEP '+' '(' lvalue ':' expr ':' expr ':' expr ')' instr { $$ = 
                      new sweep_node(int lineno, true, $4, $6, $8, $10, cdk::basic_node *block); }
*/


exprs  : expr                     { $$ = new cdk::sequence_node(LINE, $1); }
       | exprs ',' expr           { $$ = new cdk::sequence_node(LINE, $3, $1); }
       ;

insts  : inst                     { $$ = new cdk::sequence_node(LINE, $1); }
       | insts inst               { $$ = new cdk::sequence_node(LINE, $2, $1); }
       ;

vars : var                        { $$ = new cdk::sequence_node(LINE, $1); }
     | vars ',' var               { $$ = new cdk::sequence_node(LINE, $3, $1); }
     ;

decls : decl	                    { $$ = new cdk::sequence_node(LINE, $1); }
	    | decls decl                { $$ = new cdk::sequence_node(LINE, $2, $1); }
	    ;

vardecls : var	                  { $$ = new cdk::sequence_node(LINE, $1); }
	       | vardecls var           { $$ = new cdk::sequence_node(LINE, $2, $1); }
	       ;




%%
