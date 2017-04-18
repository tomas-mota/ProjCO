// $Id: memallocation_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __XPL_MEMALOCATIONNODE_H__
#define __XPL_MEMALOCATIONNODE_H__

#include <cdk/ast/unary_expression_node.h>

namespace xpl {

  /**
   * Class for describing memory allocation nodes.
   */
  class memallocation_node: public cdk::unary_expression_node{

  public:
    inline memallocation_node(int lineno, cdk::integer_node *size) :
        cdk::unary_expression_node(lineno, size) {
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_memallocation_node(this, level);
    }

  };

} // xpl

#endif
