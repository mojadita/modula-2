targets = ebnf
toclean += y.tab.h

ebnf_objs = ebnfs.o ebnfp.o tree.o main.o
toclean += ebnfs.c ebnfp.c

.include "../default.mk"

ebnfp.o ebnfs.o: y.tab.h

y.tab.h ebnfp.c: ebnfp.y
	$(YACC) $(YFLAGS) ebnfp.y
	mv -f y.tab.c ebnfp.c

ebnfs.c: ebnfs.l
	$(LEX) $(LFLAGS) ebnfs.l
	mv -f lex.yy.c $@
