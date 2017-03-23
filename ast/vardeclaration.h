// $Id: while_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __CDK_VARDECLARATIONNODE_H__
#define __CDK_VARDECLARATIONNODE_H__

#include <cdk/ast/expression_node.h>
#include <cdk/ast/lvalue_node.h>
#include <cdk/ast/basic_node.h>

namespace xpl {

  /**
   * Class for describing while-cycle nodes.
   */
  class vardeclaration_node: public cdk::basic_node {
    bool _isPublic, _isUsing;
    cdk::basic_node *_type;
    cdk::lvalue_node *_name;
    cdk::expression_node *_argument


  public:
    inline while_node(int lineno, bool isPublic, bool isUsing, cdk::basic_node *type, cdk::lvalue_node *name, cdk::expression_node *argument) :
        basic_node(lineno), _isPublic(isPublic), _isUsing(isUsing), _type(type), _name(name), _argument(argument) {
    }

  public:

    inline bool isPublic() {
      return _isPublic;
    }

    inline bool isUsing() {
      return _isUsing;
    }

    inline cdk::basic_node *type() {
      return _type;
    }

    inline cdk::lvalue_node *name() {
      return _name;
    }

    inline cdk::expression_node *argument() {
      return _argument;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_while_node(this, level);
    }

  };

} // xpl

#endif