a// $Id: if_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __CDK_BLOCKNODE_H__
#define __CDK_BLOCKNODE_H__

#include <cdk/ast/sequence_node.h>

namespace xpl {

  /**
   * Class for describing if-then nodes.
   */
  class if_node: public cdk::basic_node {
    cdk::sequence_node *_declaration, *_instruction;

  public:
    inline block_node(int lineno, cdk::sequence_node *declaration, cdk::sequence_node *instruction) :
        cdk::basic_node(lineno), _condition(condition), _block(block) {
    }

  public:
    inline cdk::sequence_node *declaration() {
      return _declaration;
    }

    inline cdk::sequence_node *instruction() {
      return _instruction;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_block_node(this, level);
    }

  };

} // xpl

#endif
