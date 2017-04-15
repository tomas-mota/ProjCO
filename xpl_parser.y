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
  xpl::fundeclaration_node   *fdec;
  xpl::fundef_node     *fdef;
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

%type <node> program var decl inst var iter arg elsif cond iter limvar
%type <sequence> decls vars insts exprs vardecls args fargs elsifs limvars
%type <expression> expr lit funcall
%type <lvalue> lval
%type <t> type
%type <s> str
%type <bl> block body
%type <fdec> fundec
%type <fdef> fundef

%{
//-- The rules below will be included in yyparse, the main parsing function.
%}
%%

program	: decls //-- { compiler->ast(new cdk::sequence_node(LINE)); }
	      ;

decl : var ';'							               { $$ = $1; }
		 | fundef							                 { $$ = $1; }
		 | fundec							                 { $$ = $1; }
		 ;

var  : tPUBLIC type tIDENTIFIER '=' expr   { $$ = new xpl::vardeclaration_node(LINE, true, false, $2, $3, $5); } 			
	   | tUSE type tIDENTIFIER '=' expr      { $$ = new xpl::vardeclaration_node(LINE, false, true, $2, $3, $5); }
	   | type tIDENTIFIER '=' expr           { $$ = new xpl::vardeclaration_node(LINE, false, false, $1, $2, $4); }
	   | type tIDENTIFIER                    { $$ = new xpl::vardeclaration_node(LINE, false, false, $1, $2, nullptr); }
     ; 

limvar : type tIDENTIFIER '=' expr           { $$ = new xpl::vardeclaration_node(LINE, false, false, $1, $2, $4); }
	     | type tIDENTIFIER                    { $$ = new xpl::vardeclaration_node(LINE, false, false, $1, $2, nullptr); }
       ;

fundec : tPROC tIDENTIFIER '(' ')'              { $$ = new xpl::fundeclaration_node
                                                (LINE, true, false, false, new basic_type(4, basic_type::TYPE_UNSPEC), $2, nullptr); }
       | tPUBLIC tPROC tIDENTIFIER '(' ')'      { $$ = new xpl::fundeclaration_node
                                                (LINE, true, true, false, new basic_type(4, basic_type::TYPE_UNSPEC), $3, nullptr); }
       | tPUBLIC type tIDENTIFIER '(' fargs ')' { $$ = new xpl::fundeclaration_node(LINE, false, true, false, $2, $3, $5); }
       | tUSE type tIDENTIFIER '(' fargs ')'    { $$ = new xpl::fundeclaration_node(LINE, false, false, true, $2, $3, $5); }
       | type tIDENTIFIER '(' fargs ')'         { $$ = new xpl::fundeclaration_node(LINE, false, false, false, $1, $2, $4); }
       ;

fundef : tPROC tIDENTIFIER '(' ')' body                       { $$ = new xpl::fundef_node
                                                              (LINE, true, false, false, new basic_type(4, basic_type::TYPE_UNSPEC), $2, nullptr, nullptr, $5); }
       | tPUBLIC tPROC tIDENTIFIER '(' ')' body               { $$ = new xpl::fundef_node
                                                              (LINE, true, true, false, new basic_type(4, basic_type::TYPE_UNSPEC), $3, nullptr, nullptr, $6); }
       | tPUBLIC type tIDENTIFIER '(' fargs ')' '=' lit body  { $$ = new xpl::fundef_node(LINE, false, true, false, $2, $3, $5, $8, $9); }
       | tPUBLIC type tIDENTIFIER '(' fargs ')' body          { $$ = new xpl::fundef_node(LINE, false, true, false, $2, $3, $5, nullptr, $7); }
       | type tIDENTIFIER '(' fargs ')' '=' lit body          { $$ = new xpl::fundef_node(LINE, false, false, false, $1, $2, $4, $7, $8); }
       | type tIDENTIFIER '(' fargs ')' '=' body              { $$ = new xpl::fundef_node(LINE, false, false, false, $1, $2, $4, nullptr, $7); }
       ; 

type : tINT			                           { $$ = new basic_type(4, basic_type::TYPE_INT); } 			
		 | tREAL		                           { $$ = new basic_type(8, basic_type::TYPE_DOUBLE); }					
		 | tSTRING			                       { $$ = new basic_type(4, basic_type::TYPE_STRING); }
		 | '[' type ']'                        { $$ = new basic_type(4, basic_type::TYPE_POINTER);}
     ;

body : '{' limvars insts '}'             { $$ = new xpl::block_node(LINE, $2, $3); }
     | '{' limvars '}'                   { $$ = new xpl::block_node(LINE, $2, nullptr); }
     | '{' insts '}'                     { $$ = new xpl::block_node(LINE, nullptr, $2); }
     | '{' '}'                           { $$ = new xpl::block_node(LINE, nullptr, nullptr); }
     ;

block : '{' vardecls insts '}'             { $$ = new xpl::block_node(LINE, $2, $3); }
      | '{' vardecls '}'                   { $$ = new xpl::block_node(LINE, $2, nullptr); }
      | '{' insts '}'                      { $$ = new xpl::block_node(LINE, nullptr, $2); }
      | '{' '}'                            { $$ = new xpl::block_node(LINE, nullptr, nullptr); }

inst : expr ';'                            { $$ = new xpl::evaluation_node(LINE, $1); }
 	   | expr tPRINT                         { $$ = new xpl::print_node(LINE, false, $1); }
 	   | expr tPRINTLN                       { $$ = new xpl::print_node(LINE, true, $1); }
     | tNEXT                               { $$ = new xpl::next_node(LINE); } 
     | tSTOP                               { $$ = new xpl::stop_node(LINE); } 
     | tRETURN                             { $$ = new xpl::return_node(LINE); } 
     | cond                                { $$ = $1; }
     | iter                                { $$ = $1; }
     | block                               { $$ = $1; }
     ;

iter : tWHILE '(' expr ')' inst                                    { $$ = new xpl::while_node(LINE, $3, $5); }
     | tSWEEP '+' '(' lval ':' expr ':' expr ':' expr ')' inst  { $$ = new xpl::sweep_node(LINE, true, $4, $6, $8, $10, $12); }
     | tSWEEP '-' '(' lval ':' expr ':' expr ':' expr ')' inst  { $$ = new xpl::sweep_node(LINE, false, $4, $6, $8, $10, $12); }
     | tSWEEP '+' '(' lval ':' expr ':' expr ')' inst           { $$ = new xpl::sweep_node(LINE, true, $4, $6, $8, nullptr, $10); }
     | tSWEEP '-' '(' lval ':' expr ':' expr ')' inst           { $$ = new xpl::sweep_node(LINE, false, $4, $6, $8, nullptr, $10); }
     ;

cond : tIF '(' expr ')' inst %prec tIFX            { $$ = new xpl::if_node(LINE, $3, $5); }
     | tIF '(' expr ')' inst tELSE inst            { $$ = new xpl::if_else_node(LINE, $3, $5, $7); } 
     | tIF '(' expr ')' inst elsifs tELSE inst     { $$ = new cdk::sequence_node(LINE); }                     //TO-DO
     ;

elsifs : elsif	                            { $$ = new cdk::sequence_node(LINE, $1); }                  
	     | elsifs elsif                       { $$ = new cdk::sequence_node(LINE, $2, $1); }
	     ;

elsif  : tELSIF '(' expr ')' inst           { $$ = new xpl::if_node(LINE, $3, $5); }
       ;


expr : lit                        { $$ = $1; }
     | funcall                    { $$ = $1; }
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
     | expr '[' expr ']'          { $$ = new xpl::indexation_node(LINE, $1, $3); }
     | '~' expr	                  { $$ = new cdk::not_node(LINE, $2); }
     | '(' expr ')'               { $$ = $2; }
     | '?' lval                   { $$ = new xpl::address_node(LINE, $2); }
     | '@'                        { $$ = new xpl::read_node(LINE); }
     | lval                       { $$ = new cdk::rvalue_node(LINE, $1); }  //FIXME
     | lval '=' expr              { $$ = new cdk::assignment_node(LINE, $1, $3); }
     | '[' tLITINT ']'            { $$ = new xpl::memallocation_node(LINE, new cdk::integer_node(LINE, $2)); }
     ;

funcall : tIDENTIFIER '(' exprs ')'		{ $$ = new xpl::funcall_node(LINE, $1, $3); }
        | tIDENTIFIER '(' ')'				  { $$ = new xpl::funcall_node(LINE, $1, nullptr); }
        ;

lit  : tLITINT                    { $$ = new cdk::integer_node(LINE, $1); }
     | str                        { $$ = new cdk::string_node(LINE, $1); }
     | tLITREAL                   { $$ = new cdk::double_node(LINE, $1); }
     | tNULL                      { $$ = nullptr;}
     ;

lval : tIDENTIFIER                { $$ = new cdk::identifier_node(LINE, $1); }
     ;

str  : tLITSTR				            { $$ = $1; }
     | str tLITSTR		            { $$ = new std::string(*$1 + *$2); }
     ; 

fargs : args			{ $$ = $1; }
      |					  { $$ = nullptr;}
		  ;

arg : type tIDENTIFIER	          { $$ = new xpl::vardeclaration_node(LINE, false, false, $1, $2, nullptr); }
    ;

args   : arg                       { $$ = new cdk::sequence_node(LINE, $1); }
       | args ',' arg              { $$ = new cdk::sequence_node(LINE, $3, $1); }
       ;

exprs  : expr                     { $$ = new cdk::sequence_node(LINE, $1); }
       | exprs ',' expr           { $$ = new cdk::sequence_node(LINE, $3, $1); }
       ;

insts  : inst                     { $$ = new cdk::sequence_node(LINE, $1); }
       | insts inst               { $$ = new cdk::sequence_node(LINE, $2, $1); }
       ;

vars   : var                        { $$ = new cdk::sequence_node(LINE, $1); }
       | vars ',' var               { $$ = new cdk::sequence_node(LINE, $3, $1); }
       ;

decls  : decl	                    { $$ = new cdk::sequence_node(LINE, $1); }
	     | decls decl                { $$ = new cdk::sequence_node(LINE, $2, $1); }
	     ;

vardecls : var	                  { $$ = new cdk::sequence_node(LINE, $1); }
	       | vardecls var           { $$ = new cdk::sequence_node(LINE, $2, $1); }
	       ;

limvars  : limvar	                { $$ = new cdk::sequence_node(LINE, $1); }
	       | limvars limvar         { $$ = new cdk::sequence_node(LINE, $2, $1); }
         ;


%%
