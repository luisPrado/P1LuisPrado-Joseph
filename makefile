P1Compi: P1Compi.c
	flex P1Compi.l
	gcc -o scanner lex.yy.c -l l
