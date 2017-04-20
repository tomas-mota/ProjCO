// $Id: vardec_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __XPL_VARDECNODE_H__
#define __XPL_VARDECNODE_H__

#include <cdk/ast/expression_node.h>
#include <cdk/basic_type.h>

namespace xpl {

  /**
   * Class for describing variable declaration nodes.
   */
  class vardec_node: public cdk::basic_node {
    bool _isPublic, _isUsing;
    basic_type *_type;
    std::string *_name;


  public:
    inline vardec_node(int lineno, bool isPublic, bool isUsing, basic_type *type, std::string *name) :
        basic_node(lineno), _isPublic(isPublic), _isUsing(isUsing), _type(type), _name(name) {
    }

  public:

    inline bool isPublic() {
      return _isPublic;
    }

    inline bool isUsing() {
      return _isUsing;
    }

    inline basic_type *type() {
      return _type;
    }

    inline std::string *name() {
      return _name;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_vardec_node(this, level);
    }

  };

} // xpl

#endif
