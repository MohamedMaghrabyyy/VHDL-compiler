parser: y.tab.c lex.yy.c
	gcc -g lex.yy.c y.tab.c -o parser

y.tab.c y.tab.h: assignment.y
	yacc -d assignment.y

lex.yy.c: assignment.l y.tab.h
	lex assignment.l

clean:
	rm -f lex.yy.c y.tab.c y.tab.h parser
