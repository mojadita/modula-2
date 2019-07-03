### MODULA-2 COMPILER

(by Luis Colorado)

This software implements a MODULA-2 compiler based on the specification
of Niklaus Wirth of 1980.  The compiler is not yet completed.  By now,
the whole grammar is parsed and the syntactic tree resul of the parsing
is shown.  The actual compiler is written in ANSI-C, without including
the C99 specifications to avoid excessive language dependencies, as a
bootstrap compiler.  Once it is fully operative, a second stage will be
initiated, in which the compiler will be rewritten in MODULA-2 in order
to be autocompilable.

If you are like me, probably you will enjoy looking at how the scanner
and parser scan the source code and see how the interpretation process
takes place.

For the moment, there's no documentation, but the original document from
Prof. Wirth, downloaded from the public repository of ETH Zurich. (both
specifications there have been downloaded and included in this project
for reference)

As of today, there's an ISO standard for MODULA-2, but I have not been
able to get a free copy of it, so I decided to implement the old
specifications, and, if we arrive to a good port, then to continue the
project to make a complete comiler.
