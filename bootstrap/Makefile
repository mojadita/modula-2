# Makefile -- makefile for the bootstrap compiler.
# Author: Luis Colorado <luiscoloradourcola@gmail.com>
# Copyright: (C) 2018 Luis Colorado.  All rights reserved.
# License: BSD
# Date: Wed May  9 08:50:53 EEST 2018

RM			?= rm -f

color_flags = -DUSE_COLOR=1

CFLAGS += -I ../avl_c $(color_flags)

STUBS1 != 	grep '^NTS(' nts.i | sed 's/NTS(\([a-zA-Z_][a-zA-Z0-9_]*\)[^)]*)/\1/'
STUBS = $(STUBS1)
STUBS_SRC = $(STUBS:S/^/stub_/:=.c)
toclean += $(STUBS_SRC) $(STUBS_SRC:.c=.o)

targets = m2c m2c1 m2c2

m2c_objs = m2c.o global.o
toclean += $(m2c_objs)

m2c1_objs = m2c1.o global.o
toclean += $(m2c1_objs)

m2c2_objs = m2s.o m2p.o symtab.o tree.o global.o \
	reduce_DefinitionModule.o \
	ts_CHARLIT.o ts_IDENT.o ts_INTEGER.o ts_MOD_IDENT.o \
	ts_NONTERMINAL.o ts_REAL.o ts_STRING.o ts_SYMBOL.o
toclean += $(m2c2_objs)
m2c2_deps = libstubs.a
m2c2_ldflags = -L ../avl_c -L .
m2c2_libs = -lavl -lstubs
toclean += m2s.c m2p.c m2c1.c y.tab.h libstubs.a

all: $(targets)
	@echo Last Compilation made on `LANG=C date` | tee all >&2
.depend: $(STUBS_SRC) $(m2c_objs:.o=.c) $(m2c1_objs:.o=.c) $(m2c2_objs:.o=.c)
	$(CC) $(CFLAGS) -M $> >.depend

.include "../default.mk"

m2p.o: m2p.h token.i y.tab.h
y.tab.h m2p.c: m2p.y
	$(YACC) $(YFLAGS) -d m2p.y
	mv -f y.tab.c m2p.c
m2s.o: m2s.c m2p.h token.i y.tab.h
tree.o: m2p.h tnt.i nts.i tree.h tree.h

$(STUBS_SRC):
	mkstubs.sh $(@:S/^stub_//:.c=)

libstubs.a: mkstubs.sh
	mkstubs.sh $(STUBS_SRC:S/^stub_//:.c=)
	$(CC) $(CFLAGS) -c $(STUBS_SRC)
	$(AR) $(ARFLAGS) $@ $(STUBS_SRC:.c=.o)
	ranlib $@
	...
	$(RM) $(STUBS_SRC:.c=.o) $(STUBS_SRC)
