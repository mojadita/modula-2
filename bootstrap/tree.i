/* this list must maintain the same order as the nonterminals
 * in the rules of the yacc grammar.  The reason is that they
 * get assigned numbers by yacc and to map those numbers to
 * the index names, they must be listed in the same order.
 */
NT(CompilationUnit)
NT(qualident)
NT(qualifier)
NT(ConstantDeclaration)
NT(ConstExpression)
NT(relation)
NT(SimpleConstExpr)
NT(ConstTerm_list)
NT(add_op_opt)
NT(AddOperator)
NT(ConstTerm)
NT(MulOperator)
NT(ConstFactor)
NT(set)
NT(element_list_opt)
NT(element_list)
NT(element)
NT(TypeDeclaration)
NT(type)
NT(SimpleType)
NT(enumeration)
NT(IdentList)
NT(SubrangeType)
NT(ArrayType)
NT(SimpleType_list)
NT(RecordType)
NT(FieldListSequence)
NT(FieldList)
NT(case_ident)
NT(variant_list)
NT(ELSE_FieldListSequence)
NT(variant)
NT(CaseLabelList)
NT(CaseLabels)
NT(SetType)
NT(PointerType)
NT(ProcedureType)
NT(FormalTypeList)
NT(paren_formal_parameter_type_list_opt)
NT(formal_parameter_type_list_opt)
NT(formal_parameter_type_list)
NT(formal_parameter_type)
NT(VariableDeclaration)
NT(designator)
NT(ExpList)
NT(expression)
NT(SimpleExpression)
NT(term)
NT(factor)
NT(ActualParameters)
NT(statement)
NT(assignment)
NT(ProcedureCall)
NT(StatementSequence)
NT(IfStatement)
NT(elsif_seq)
NT(else_opt)
NT(CaseStatement)
NT(case_list)
NT(case)
NT(WhileStatement)
NT(RepeatStatement)
NT(ForStatement)
NT(by_opt)
NT(LoopStatement)
NT(WithStatement)
NT(ProcedureDeclaration)
NT(ProcedureHeading)
NT(FormalParameters_opt)
NT(block)
NT(declaration_list_opt)
NT(BEGIN_StatementSequence_opt)
NT(declaration)
NT(ConstantDeclaration_list_opt)
NT(TypeDeclaration_list_opt)
NT(VariableDeclaration_list_opt)
NT(FormalParameters)
NT(FPSection_list_opt)
NT(FPSection_list)
NT(FPSection)
NT(FormalType)
NT(ModuleDeclaration)
NT(priority_opt)
NT(import_list_opt)
NT(export_opt)
NT(import)
NT(DefinitionModule)
NT(definition_list_opt)
NT(definition)
NT(opaque_type_list_opt)
NT(opaque_type)
NT(ProgramModule)
