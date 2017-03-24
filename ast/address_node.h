// $Id: adress_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __CDK_ADDRESSNODE_H__
#define __CDK_ADDRESSNODE_H__

#include <cdk/ast/expression_node.h>
#include <cdk/ast/lvalue_node.h>

namespace xpl {

  /**
   * Class for describing address nodes.
   */
  class address_node: public cdk::rvalue_node {

  public:
    inline if_node(int lineno, cdk::lvalue_node *value) :
        cdk::basic_node(lineno), _lvalue(value) {
    }

  public:
    inline cdk::lvalue_node *value() {
      return _lvalue
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_address_node(this, level);
    }

  };

} // xpl

#endif