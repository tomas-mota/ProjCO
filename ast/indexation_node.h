// $Id: indexation_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __XPL_INDEXATIONNODE_H__
#define __XPL_INDEXATIONNODE_H__

#include <cdk/ast/expression_node.h>
#include <cdk/ast/lvalue_node.h>

namespace xpl {

  /**
   * Class for describing if-then nodes.
   */
  class indexation_node: public cdk::lvalue_node {
    cdk::expression_node *_ptr, *_index;

  public:
    inline indexation_node(int lineno, cdk::expression_node *ptr, cdk::expression_node *index) :
        cdk::lvalue_node(lineno), _ptr(ptr), _index(index) {
    }

  public:

    inline cdk::expression_node *ptr() {
      return _ptr;
    }

    inline cdk::expression_node *index() {
      return _index;
    }    

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_indexation_node(this, level);
    }

  };

} // xpl

#endif
