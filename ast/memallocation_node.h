// $Id: memallocation_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __CDK_MEMALOCATIONNODE_H__
#define __CDK_MEMALOCATIONNODE_H__

#include <cdk/ast/integer_node.h>
#include <cdk/ast/expression_node.h>
#include <cdk/basic_type.h>

namespace xpl {

  /**
   * Class for describing memory allocation nodes.
   */
  class memallocation_node: public cdk::expression_node {
    basic_type *_type;
    std::string _nome;
    cdk::integer_node *_size;

  public:
    inline memallocation_node(int lineno, basic_type *type, std::string nome, cdk::integer_node *size) :
        cdk::expression_node(lineno), _type(type), _nome(nome), _size(size) {
    }

  public:

    inline basic_type *type() {
      return _type;
    }

    inline std::string nome() {
      return _nome;
    }

    inline cdk::integer_node *size() {
      return _size;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_memallocation_node(this, level);
    }

  };

} // xpl

#endif
