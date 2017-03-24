// $Id: if_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __CDK_MEMALOCATIONNODE_H__
#define __CDK_MEMALOCATIONNODE_H__

#include <cdk/ast/integer_node.h>
#include <cdk/basic_type.h>

namespace xpl {

  /**
   * Class for describing memory allocation nodes.
   */
  class indexation_node: public cdk::lvalue_node {
    cdk::basic_type *_type;
    String _nome;
    cdk::integer_node *_size;

  public:
    inline if_node(int lineno, cdk::basic_type *type, String nome, cdk::integer_node *size) :
        cdk::basic_node(lineno), _type(type), _nome(nome), _size(size) {
    }

  public:

    inline cdk::basic_type type() {
      return _type;
    }

    inline String nome()) {
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
