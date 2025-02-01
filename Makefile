CC=gcc
CFLAGS=-g -Wall

proj: flex.def.lex.c bison.def.tab.c src/stack.c src/value.c src/ast.c src/queue.c
	$(CC) $(CFLAGS) -o $@ $^

bison.def.tab.o: bison.def.tab.c bison.def.tab.h

flex.def.lex.o: flex.def.lex.c

bison.def.tab.c bison.def.tab.h: bison.def.y
	bison --report=all --defines -Wcounterexamples -t $^

flex.def.lex.c: flex.def.l
	flex -o $@ $^

clean:
	rm -f bison.def.tab.* flex.def.lex.* bison.def.output

purge: clean
	rm -f proj
