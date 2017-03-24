// $Id: fundeclaration_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __CDK_funDECLARATIONNODE_H__
#define __CDK_funDECLARATIONNODE_H__

#include <cdk/ast/sequence_node.h>
#include <cdk/basic_type.h>
#include <block_node.h>

namespace xpl {

  /**
   * Class for describing function declaration nodes.
   */
  class fundeclaration_node: public cdk::basic_node {
    bool _isProcedure, _isPublic, _isUsing;
    cdk::basic_type *_type;
    String _name;
    cdk::sequence_node *_variables;
    cdk::literal_node *_literal;
    block_node *_body;


  public:
    inline fundeclaration_node(int lineno, bool isProcedure, bool isPublic, bool isUsing, cdk::basic_type *type,
                              String name, cdk::sequence_node *variables, cdk::literal_node *literal, block_node *body) :
        basic_node(lineno), _isPublic(isPublic), _isUsing(isUsing), _type(type), _name(name), _argument(argument) {
    }

  public:

    inline bool isProcedure() {
      return _isProcedure;
    }

    inline bool isPublic() {
      return _isPublic;
    }

    inline bool isUsing() {
      return _isUsing;
    }

    inline cdk::basic_type *type() {
      return _type;
    }

    inline String name() {
      return _name;
    }

    inline cdk::sequence_node *variables() {
      return _variables;
    }

    inline cdk::literal_node *literal() {
      return _literal;
    }

    inline block_node *body(){
      return _body
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_fundeclaration_node(this, level);
    }

  };

} // xpl

#endif
