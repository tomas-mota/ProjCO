// $Id: if_else_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __CDK_SWEEPNODE_H__
#define __CDK_SWEEPNODE_H__

#include <cdk/ast/expression_node.h>

namespace xpl {

  /**
   * Class for describing sweep nodes.
   */
  class sweep_node: public cdk::basic_node {
    bool isIncremental;
    cdk::lvalue_node *_value;
    cdk::expression_node *limit, *increment;

  public:
    inline sweep_node(int lineno, bool isIncremental, cdk::lvalue_node *value, cdk::expression_node *initValue, cdk::expression_node *limit, cdk::expression_node *increment) :
        cdk::basic_node(lineno), _condition(condition), _thenblock(thenblock), _elseblock(elseblock) {
    }

  public:
    inline cdk::expression_node *condition() {
      return _condition;
    }
    inline cdk::basic_node *thenblock() {
      return _thenblock;
    }
    inline cdk::basic_node *elseblock() {
      return _elseblock;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_if_else_node(this, level);
    }

  };

} // xpl

#endif
