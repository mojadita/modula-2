/* ebnfs.h -- scanner definitions.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed May 16 11:58:35 EEST 2018
 */
#ifndef EBNFS_H
#define EBNFS_H

typedef struct bnf_token {
	unsigned 	 t_lin,
				 t_col;
	int			 t_token;
	char		*t_lexem;
} *bnf_token_t;

#endif /* EBNFS_H */
