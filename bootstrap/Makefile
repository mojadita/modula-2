# Makefile -- makefile for the bootstrap compiler.
# Author: Luis Colorado <luiscoloradourcola@gmail.com>
# Date: Wed May  9 08:50:53 EEST 2018

CFLAGS += -I ../avl_c

targets = m2c1 m2c2

m2c1_objs = m2c1.o
toclean += $(m2c1_objs)

m2c2_objs = m2s.o m2p.o symtab.o
toclean += $(m2c2_objs)
m2c2_deps = 
m2c2_ldflags = -L ../avl_c
m2c2_libs = -lavl -ly
toclean += m2s.c m2p.c y.tab.h

all: $(targets)

.include "../default.mk"

m2p.o: m2p.h m2p.i y.tab.h
y.tab.h m2p.c: m2p.y
	$(YACC) $(YFLAGS) -d m2p.y
	mv -f y.tab.c m2p.c
m2s.o: m2s.c m2p.h m2p.i y.tab.h
