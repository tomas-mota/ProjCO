// $Id: print_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __XPL_PRINTNODE_H__
#define __XPL_PRINTNODE_H__

#include <cdk/ast/expression_node.h>

namespace xpl {

  /**
   * Class for describing print nodes.
   */
  class print_node: public cdk::basic_node {
    bool _newline;
    cdk::expression_node *_argument;

  public:
    inline print_node(int lineno, bool newline, cdk::expression_node *argument) :
        cdk::basic_node(lineno), _newline(newline), _argument(argument) {
    }

  public:
    inline bool newline() {
      return _newline;
    }

    inline cdk::expression_node *argument() {
      return _argument;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_print_node(this, level);
    }

  };

} // xpl

#endif
