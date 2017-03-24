// $Id: funcall_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __CDK_FUNCALLNODE_H__
#define __CDK_FUNCALLNODE_H__

#include <cdk/ast/sequence_node.h>
#include <cdk/ast/identifier_node>

namespace xpl {

  /**
   * Class for describing function call  nodes.
   */
  class funcall_node: public cdk::basic_node {
    cdk::identifier_node *_name;
    cdk::sequence_node *_variables;

  public:
    inline funcall_node(int lineno, cdk::identifier_node *name, cdk::sequence_node *variables) :
        cdk::basic_node(lineno), _name(name), _variables(variables) {
    }

  public:
    inline cdk::identifier_node *name() {
      return _name;
    }

    inline cdk::sequence_node *variables() {
      return _variables;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_funcall_node(this, level);
    }

  };

} // xpl

#endif
