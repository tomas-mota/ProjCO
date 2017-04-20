// $Id: fundeclaration_node.h,v 1.1 2017/02/17 16:02:31 david Exp $ -*- c++ -*-
#ifndef __CDK_funDECLARATIONNODE_H__
#define __CDK_funDECLARATIONNODE_H__

#include <cdk/ast/sequence_node.h>
#include <cdk/ast/basic_node.h>
#include <cdk/basic_type.h>

namespace xpl {

  /**
   * Class for describing function declaration nodes.
   */
  class fundeclaration_node: public cdk::basic_node {
    bool _isProcedure, _isPublic, _isUsing;
    basic_type *_type;
    std::string *_name;
    cdk::sequence_node *_arguments;


  public:
    inline fundeclaration_node(int lineno, bool isProcedure, bool isPublic, bool isUsing, basic_type *type,
                              std::string *name, cdk::sequence_node *arguments) :
        basic_node(lineno), _isProcedure(isProcedure), _isPublic(isPublic), _isUsing(isUsing), _type(type), _name(name), _arguments(arguments){
    }

  public:

    inline bool isProcedure() {
      return _isProcedure;
    }

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

    inline cdk::sequence_node *arguments() {
      return _arguments;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_fundeclaration_node(this, level);
    }

  };

} // xpl

#endif
