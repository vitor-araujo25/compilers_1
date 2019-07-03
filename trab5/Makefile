all: saida
	./saida

saida: codigo.cc
	g++ -o saida codigo.cc

codigo.cc: mlc exemplo.ml gabarito
	./mlc < exemplo.ml > codigo.cc
	./gabarito < codigo.cc

lex.yy.c: expressoes.lex
	lex expressoes.lex

y.tab.c: expressoes.y
	yacc expressoes.y

mlc: lex.yy.c y.tab.c
	g++ -o mlc y.tab.c -lfl

gabarito:
	cd gab && make && cd ..

clean:
	rm -f codigo.cc gabarito lex.yy.c mlc saida y.tab.c
