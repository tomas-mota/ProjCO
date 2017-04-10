// $Id: if_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __CDK_INDEXATIONNODE_H__
#define __CDK_INDEXATIONNODE_H__

#include <cdk/ast/expression_node.h>
#include <cdk/ast/lvalue_node.h>

namespace xpl {

  /**
   * Class for describing if-then nodes.
   */
  class indexation_node: public cdk::lvalue_node {
    std::string _nome;
    cdk::expression_node *_value;

  public:
    inline indexation_node(int lineno, std::string nome, cdk::expression_node *value) :
        cdk::lvalue_node(lineno), _nome(nome), _value(value) {
    }

  public:
    inline std::string nome() {
      return _nome;
    }

    inline cdk::expression_node *value() {
      return _value;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_indexation_node(this, level);
    }

  };

} // xpl

#endif
