targets = ebnf
toclean += y.tab.h

ebnf_objs = ebnfs.o ebnfp.o tree.o main.o
toclean += ebnfs.c ebnfp.c

.include "../default.mk"

ebnfp.o ebnfs.o: y.tab.h

y.tab.h ebnfp.c: ebnfp.y
	$(YACC) $(YFLAGS) -d ebnfp.y
	mv -f y.tab.c ebnfp.c
