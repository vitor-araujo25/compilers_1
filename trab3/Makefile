codigo.cc: compilador entrada.txt
	./compilador < entrada.txt > codigo.cc

compilador: main.cc y.tab.c
	g++ -std=c++17 -Wall main.cc -lfl -o compilador

y.tab.c: lex.yy.c gera_listas.y
	yacc gera_listas.y

lex.yy.c: gera_listas.lex
	lex gera_listas.lex

teste: main_programa_gerado.cc codigo.cc
	g++ -std=c++17 main_programa_gerado.cc codigo.cc -o programa_gerado
	./programa_gerado

clean:
	rm -f y.tab.c lex.yy.c compilador codigo.cc programa_gerado
