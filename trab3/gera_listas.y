%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

using namespace std;

#define YYSTYPE Atributos

int linha = 1;
int coluna = 1;
int numero_de_nos = 0;

struct Atributos {
  string head;
  string codigo;
};

//struct Lista {
// bool sublista; 
// string valorString;
// Lista* valorSublista;
// Lista* proximo;  
//;


Atributos gera_codigo_atomo( Atributos s1 );
Atributos gera_ultimo_elemento( Atributos s1 );
Atributos gera_lista_vazia();
Atributos gera_novo_elemento( Atributos s1,  Atributos s2 );
Atributos gera_sublista( Atributos s1 );

void imprime_saida( Atributos s1 );
%}

%start S

%token ATOMO 

%%

S : L          { imprime_saida( $1 ); }
    ;
  
L :	'(' LE ')'		{ $$ = $2; }
    | '(' ')'    { $$ = gera_lista_vazia(); }
  ;

LE : E ',' LE { $$ = gera_novo_elemento( $1, $3 ); }
      | E        { $$ = gera_ultimo_elemento( $1 ); }
   ;
  
E : L         { $$ = gera_sublista( $1 ); }
    | ATOMO     { $$ = gera_codigo_atomo( $1 ); }
  ;
  
%%

#include "lex.yy.c"

Atributos gera_sublista( Atributos s1 ) {
  Atributos ss;

  ss.head = "l" + to_string( numero_de_nos++ );
  
  ss.codigo = s1.codigo + "\n"
            + ss.head + "->sublista = true;\n"
            + ss.head + "->valorString = \"\";\n"
            + ss.head + "->valorSublista = " + s1.head +";\n";

  return ss; 
}

Atributos gera_novo_elemento( Atributos s1,  Atributos s3 ) {
  Atributos ss;
     
  ss.codigo = s1.codigo 
	    + s1.head + "->proximo = " + s3.head + ";\n\n"
	    + s3.codigo;
  ss.head = s1.head;
       
  return ss;     
}

Atributos gera_ultimo_elemento( Atributos s1 ) {
  Atributos ss;
  
  ss.codigo = s1.codigo 
            + s1.head + "->proximo = nullptr;\n"; 
  ss.head = s1.head;
  
  return ss;
}

void imprime_saida( Atributos s1 ) {

	cout << "#include <string>\n" <<
		"using namespace std;\n" << endl;

	cout << "struct Lista {\n" <<
		"bool sublista;\n" <<
		"string valorString;\n" <<
		"Lista* valorSublista;\n" <<
		"Lista* proximo;\n" <<
	"};\n" << endl;

	cout << "Lista* geraLista() {\n";
	
	for( int i = 0; i < numero_de_nos; i++ ){
    	cout << "Lista *l" << i << ";\n";
		cout << "l" << i << " = new Lista;\n";
	}
	  
  cout << "\n" + s1.codigo << endl; 
        
  cout << "return " << s1.head << ";\n};" << endl;  
}

Atributos gera_lista_vazia() {
  Atributos ss = { "nullptr", "" };

  return ss;
}

Atributos gera_codigo_atomo( Atributos s1 ) {
  Atributos ss;
  
  ss.head = "l" + to_string( numero_de_nos++ );
	     
  ss.codigo = ss.head + "->sublista = false;\n"
            + ss.head + "->valorString = \"" + s1.head + "\";\n"
            + ss.head + "->valorSublista = nullptr;\n";

  return ss;
}

void yyerror( const char* st ) {
   puts( st ); 
   cout << "Linha " << linha 
        << " , coluna " << coluna - yyleng 
        << ", proximo a: " << yytext<< endl;
        
   exit( 0 );
}
