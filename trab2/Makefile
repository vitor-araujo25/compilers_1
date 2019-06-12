all: saida teste1 teste2 teste3 teste4 teste5
	./saida < teste1
	./saida < teste2
	./saida < teste3
	./saida < teste4
	./saida < teste5
	
lex.yy.c: trab1.lex
	lex trab1.lex

saida: lex.yy.c 
	g++ lex.yy.c -o saida -lfl
	
clean:
	rm saida lex.yy.c