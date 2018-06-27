/* ttype.i -- TERM TYPE definitions.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue Jun 26 19:46:15 EEST 2018
 *
 * The macro TTYPE will
 * be defined differently for inclusion in several
 * places, with the purpose of having a unique point
 * of definition and automagically generate the proper
 * definitions at the different places. */
TTYPE(ident, T_IDENT, const_bnf_token_t, t_ident, "%s")
TTYPE(reptd, T_REPTD, bnf_alternative_set_t, t_reptd, "%p")
TTYPE(optnl, T_OPTNL, bnf_alternative_set_t, t_optnl, "%p")
TTYPE(paren, T_PAREN, bnf_alternative_set_t, t_paren, "%p")
TTYPE(strng, T_STRNG, const_bnf_token_t, t_strng, "%p")
