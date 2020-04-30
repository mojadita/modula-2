/* m2p.h -- definitions for the MODULA-2 parser.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue Aug 21 08:32:18 EEST 2018
 * Copyright: (C) 2018-2020 LUIS COLORADO.  All rights reserved.
 * License: BSD
 */
#ifndef M2P_H
#define M2P_H

#include <sys/types.h>

#include "tree.h"
#include "y.tab.h"

extern int yylex(void);

struct res_word {
       const int token_val;
       const char * const lexem;
};

#endif /* M2P_H */
