%{ // Código em C/C++
#include <stdio.h>
#include <string>

using namespace std;

extern "C" int yylex();
extern char* yytext;

enum TOKEN { _ID = 256, _FOR, _IF, _INT, _FLOAT, _MAIG, _MEIG, _IG, _DIF, _STRING, _COMENTARIO };

%}


/* Coloque aqui definições regulares */

WS	[ \t\n]
D	[0-9]
L	[A-Za-z_]

COMM (\/\*)(\*[^\/]|[^\*])*(\*\/)
INT	{D}+
FLOAT {INT}(\.{INT})?([Ee][+-]?{INT})?
ID	{L}({L}|{D})*
STR \"([^\"]|\\\"|{WS})+\"

%%
    /* Padrões e ações. Nesta seção, comentários devem ter um tab antes */
    /* TOKENS:
        _ID     letra ou _ seguido por letra, digito ou _
        _INT 
        _FLOAT  ponto flutuante e notação científica
        _FOR
        _IF
        _MAIG   >=
        _MEIG   <=
        _IG     ==
        _DIF    !=
        _COMENTARIO multi-linha, sem comentários aninhados, não juntar comentários separados   
        _STRING começa e termina com aspas, escapar com \ ou "", strings não pulam linha

    */

{COMM}  {return _COMENTARIO;}

{STR} {return _STRING;}

{INT}   {return _INT;}

{FLOAT} {return _FLOAT;}

"if"    {return _IF;}

"for"   {return _FOR;}

">="    {return _MAIG;}

"<="    {return _MEIG;}

"=="    {return _IG;}

"!="    {return _DIF;}

{WS}	{/* ignora espaços, tabs e '\n' */} 

{ID}    {return _ID;}

.       { return *yytext; 
          /* Essa deve ser a última regra. Dessa forma qualquer caractere isolado será retornado pelo seu código ascii. */ }

%%

/* Não coloque nada aqui - a função main é automaticamente incluída na hora de avaliar e dar a nota. */

int main() {
  int token = 0;
  
  while( (token = yylex()) != 0 )  
    printf( "Token: %d %s\n", token, yytext );
  
  return 0;
}
