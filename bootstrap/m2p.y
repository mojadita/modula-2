%{
/* m2p.y -- parser for MODULA-2.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue Aug 21 08:10:26 EEST 2018
 * Based on the MODULA-2 report by N. Wirth, 1978.
 * See: https://doi.org/10.3929/ethz-a-000153014
 */

#include "m2p.h"
%}

%token AND ARRAY TBEGIN BY CASE CONST DEFINITION DIV DO ELSE ELSIF
%token END EXIT EXPORT FOR FROM IF IMPORT IN LOOP MOD MODULE NOT
%token OF OR POINTER PROCEDURE QUALIFIED RECORD REPEAT TRETURN
%token SET THEN TO TYPE UNTIL VAR WHILE WITH

%token ASSIGN LE GE RANGE
%token BAD_TOKEN


%%

compilation: TBEGIN END;

%%

const struct res_word res_word_tab[] = {
#define TOKEN(nam, pfx) { pfx##nam, #nam },
#include "m2p.i"
#undef TOKEN
};
const size_t res_word_tabsz = sizeof res_word_tab / sizeof res_word_tab[0];
