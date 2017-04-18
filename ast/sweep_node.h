// $Id: sweep_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __XPL_SWEEPNODE_H__
#define __XPL_SWEEPNODE_H__

#include <cdk/ast/expression_node.h>
#include <cdk/ast/lvalue_node.h>
#include <cdk/ast/basic_node.h>


namespace xpl {

  /**
   * Class for describing sweep nodes.
   */
  class sweep_node: public cdk::basic_node {
    bool _isIncremental;
    cdk::lvalue_node *_iter;
    cdk::expression_node *_initValue, *_limit, *_increment;
    cdk::basic_node *_block;

  public:
    inline sweep_node(int lineno, bool isIncremental, cdk::lvalue_node *iter, cdk::expression_node *initValue,
                          cdk::expression_node *limit, cdk::expression_node *increment, cdk::basic_node *block) :
        cdk::basic_node(lineno), _isIncremental(isIncremental), _iter(iter), _initValue(initValue), _limit(limit), _increment(increment), _block(block) {
    }

  public:

    inline bool isIncremental() {
      return _isIncremental;
    }

    inline cdk::lvalue_node *iter() {
      return _iter;
    }

    inline cdk::expression_node *initValue() {
      return _initValue;
    }

    inline cdk::expression_node *limit() {
      return _limit;
    }

    inline cdk::expression_node *increment() {
      return _increment;
    }

    inline cdk::basic_node *block() {
      return _block;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_sweep_node(this, level);
    }

  };

} // xpl

#endif
