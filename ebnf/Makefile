
targets = ebnf
toclean += y.tab.h

CFLAGS += -I ../avl_c

ebnf_objs = ebnfs.o ebnfp.o main.o bgram.o brule.o balts.o balt.o bterm.o
ebnf_libs = -lavl
ebnf_ldflags = -L ../avl_c
toclean += ebnfs.c ebnfp.c

.include "../default.mk"

ebnfp.o ebnfs.o: y.tab.h

y.tab.h ebnfp.c: ebnfp.y
	$(YACC) $(YFLAGS) ebnfp.y
	mv -f y.tab.c ebnfp.c

.depend: $(ebnf_objs:.o=.c)
	mkdep $(CFLAGS) $(ebnf_objs:.o=.c)

ebnfs.c: ebnfs.l
	$(LEX) $(LFLAGS) ebnfs.l
	mv -f lex.yy.c $@
