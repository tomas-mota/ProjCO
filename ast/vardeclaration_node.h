// $Id: vardeclaration_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __CDK_VARDECLARATIONNODE_H__
#define __CDK_VARDECLARATIONNODE_H__

#include <cdk/ast/expression_node.h>
#include <cdk/basic_type.h>

namespace xpl {

  /**
   * Class for describing variable declaration nodes.
   */
  class vardeclaration_node: public cdk::basic_node {
    bool _isPublic, _isUsing;
    basic_type *_type;
    std::string *_name;
    cdk::expression_node *_argument;


  public:
    inline vardeclaration_node(int lineno, bool isPublic, bool isUsing, basic_type *type, std::string *name, cdk::expression_node *argument) :
        basic_node(lineno), _isPublic(isPublic), _isUsing(isUsing), _type(type), _name(name), _argument(argument) {
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

    inline cdk::expression_node *argument() {
      return _argument;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_vardeclaration_node(this, level);
    }

  };

} // xpl

#endif
