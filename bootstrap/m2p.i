/* m2p.i -- tokens of MODULA-2 language.
 * tokens must be in alphabetical order, as they are searched with a binary search algorithm.
 * beware that this file must be in synch with m2p.y, as tokens are defined there as well.
 * Here are ***ONLY*** tokens that are reserved words, matching also as identifiers, and
 * there are ***all*** tokens defined with %token keyword.
 * First parameter spells exactly the keyword as it appears in the language, while second
 * parameter specifies the prefix used in the %token identifier, to avoid name clashes in
 * source code.  At this moment, only BEGIN and RETURN require this (its name clashes with
 * the lex(1) definitions or ours)
 */
TOKEN(AND,)
TOKEN(ARRAY,)
TOKEN(BEGIN,T)
TOKEN(BY,)
TOKEN(CASE,)
TOKEN(CONST,)
TOKEN(DEFINITION,)
TOKEN(DIV,)
TOKEN(DO,)
TOKEN(ELSE,)
TOKEN(ELSIF,)
TOKEN(END,)
TOKEN(EXIT,)
TOKEN(EXPORT,)
TOKEN(FOR,)
TOKEN(FROM,)
TOKEN(IF,)
TOKEN(IMPORT,)
TOKEN(IN,)
TOKEN(LOOP,)
TOKEN(MOD,)
TOKEN(MODULE,)
TOKEN(NOT,)
TOKEN(OF,)
TOKEN(OR,)
TOKEN(POINTER,)
TOKEN(PROCEDURE,)
TOKEN(QUALIFIED,)
TOKEN(RECORD,)
TOKEN(REPEAT,)
TOKEN(RETURN,T)
TOKEN(SET,)
TOKEN(THEN,)
TOKEN(TO,)
TOKEN(TYPE,)
TOKEN(UNTIL,)
TOKEN(VAR,)
TOKEN(WHILE,)
TOKEN(WITH,)
