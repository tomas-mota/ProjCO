// $Id: program_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __XPL_STOPNODE_H__
#define __XPL_STOPNODE_H__

#include <cdk/ast/basic_node.h>

namespace xpl {

  /**
   * Class for describing stop nodes.
   */
  class stop_node: public cdk::basic_node {


  public:
    inline stop_node(int lineno) :
        cdk::basic_node(lineno) {
    }


    void accept(basic_ast_visitor *sp, int level) {
      sp->do_stop_node(this, level);
    }

  };

} // xpl

#endif
