%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>

using namespace std;

#define YYSTYPE Atributos

int linha = 1;
int coluna = 1;

struct Atributos {
  string v;
  string c;
  int linha;
};

extern "C" int yylex();
int yyparse();
void yyerror(const char *);

void gera_programa( Atributos a);
string gera_temp();
string gera_label();
Atributos gera_not(Atributos param);
Atributos gera_codigo_atribuicao( Atributos lvalue, Atributos rvalue );
Atributos gera_codigo_operacao( Atributos param1, Atributos opr, Atributos
param2 );

map<string, string> ts;

%}

%start S
%token CINT CDOUBLE CSTR TK_ID TK_VAR TK_CONSOLE TK_SHIFTR TK_SHIFTL
%token TK_FOR TK_IN TK_2PT TK_IF TK_THEN TK_ELSE TK_ENDL
%token TK_GE TK_LE TK_G TK_L TK_AND TK_OR TK_NOT TK_EQ TK_NEQ TK_BEGIN TK_END

%left TK_OR
%left TK_AND
%left TK_EQ TK_NEQ
%left TK_L TK_LE TK_G TK_GE
%left '+' '-'
%left '*' '/' '%'
%left TK_NOT

%%

S : CMDS { gera_programa($1); }
    ;  

CMDS : CMDS CMD { $$.c = $1.c + $2.c; }
	 	 | CMD 
     ;
  
CMD : DECLVAR ';' 
		| ENTRADA ';'
    | SAIDA ';'
    | ATR 
    | FOR
    | IF
    ;
    
DECLVAR : TK_VAR VARS { $$.c = "int " + $2.c + ";\n"; }
		        ;
    
VARS : VARS ',' VAR  { $$.c = $1.c + ", " + $3.c; }
	    	 | VAR
     ;
     
VAR : TK_ID '[' CINT ']' { $$.c = $1.v + "[" + $3.v + "]"; }
	    | TK_ID              { $$.c = $1.v; }
    ;
    
ENTRADA : TK_CONSOLE TK_SHIFTR IN_PARAM { $$.c = $3.c; }
		        ;
		
IN_PARAM : IN_PARAM TK_SHIFTR TK_ID { $$.c = $1.c + "cin >> " + $3.v + ";\n";
		 }
        | IN_PARAM TK_SHIFTR TK_ID '[' E ']'
          { $$.c = $5.c + $1.c +
                "cin >> " + $3.v + "[" + $5.v + "] = " + ";\n";
			 }
		| TK_ID { $$.c = "cin >> " + $1.v + ";\n"; }
		| TK_ID '[' E ']' 
			{$$.c = $3.c + "cin >> " + $1.v + "[" + $3.v + "]" + ";\n";}
        ;
  
SAIDA : TK_CONSOLE TK_SHIFTL OUT_PARAM { $$.c = $3.c; }
	        ;

OUT_PARAM : OUT_PARAM TK_SHIFTL CSTR 
		  			  { $$.c = $1.c + "cout << " + $3.v + ";\n";}
		  | OUT_PARAM TK_SHIFTL E 
			{$$.c = $3.c + $1.c + "cout << " + $3.v + ";\n";}
		  | OUT_PARAM TK_SHIFTL TK_ENDL
			 { $$.c = $3.c +$1.c + "cout << endl;\n";}
		  | CSTR {$$.c = "cout << " + $1.v + ";\n";}
		  | E {$$.c = $1.c + "cout << " + $1.v + ";\n";}
		  | TK_ENDL {$$.c = $1.c + "cout << endl;\n";}
		  ;
        
FOR : TK_FOR TK_ID TK_IN '[' E TK_2PT E ']' BLOCK 
		    {  string cond = gera_temp();
       	string meio = gera_label(), fim = gera_label();
       $$.c = $5.c + $7.c 
            + $2.v + " = " + $5.v + ";\n"
            + meio + ":\n" + cond + " = " + $2.v + " > " + $7.v + ";\n"
            + "if( " + cond + ") goto "+fim+";\n"
            + $9.c
            + $2.v + " = " + $2.v + " + 1;\n"
            + "goto "+meio+";\n"
            + fim+":\n";
    }        
    ;
    
IF :  TK_IF E TK_THEN BLOCK TK_ELSE BLOCK
   		{
		string l1 = gera_label(), l2 = gera_label();
		$$.c = $2.c + "if(" + $2.v + ") goto " + l1 + ";\n" + $6.c
		 + "goto " + l2 + ";\n" + l1 + ":\n" + $4.c + l2 + ":\n";	
		}

   |  TK_IF E TK_THEN BLOCK TK_ELSE IF ';'
   		{
		string l1 = gera_label(), l2 = gera_label();
		$$.c = $2.c + "if(" + $2.v + ") goto " + l1 + ";\n" + $6.c
		 + "goto " + l2 + ";\n" + l1 + ":\n" + $4.c + l2 + ":\n";	
		}
   |  TK_IF E TK_THEN BLOCK
		{
		string l1 = gera_label();
		$$.c = $2.c + $2.v + " = !" + $2.v + ";\nif(" + $2.v + ") goto "
		+ l1 + ";\n" + $4.c + l1 + ":\n";
		}

   ;
 
BLOCK : TK_BEGIN CMDS TK_END {$$.c = $2.c;}
	  	  | TK_BEGIN TK_END {$$.c = "\n";}
      | TK_BEGIN CMDS TK_END ';' {$$.c = $2.c;}
	  | TK_BEGIN TK_END ';' {$$.c = "\n";}
	  | CMD { $$.c = $1.c; }
	;

ATR : TK_ID '=' E ';'
		      { $$.v = $3.v;
        $$.c = $3.c + $1.v + " = " + $3.v + ";\n";
      }
    | TK_ID '[' E ']' '=' E ';'
      { $$.c = $3.c + $6.c 
             + $1.v + "[" + $3.v + "] = " + $6.v + ";\n";
        $$.v = $6.v;
      }
    ;
  
E : E '+' E { $$ = gera_codigo_operacao($1, $2, $3);}
    | E '-' E {  $$ = gera_codigo_operacao($1, $2, $3);    }
  | E '*' E { $$ = gera_codigo_operacao($1, $2, $3);    }
  | E '/' E { $$ = gera_codigo_operacao($1, $2, $3);    }
  | E '%' E     { $$ = gera_codigo_operacao($1,$2,$3); }
  | E TK_G E	{ $$ = gera_codigo_operacao($1,$2,$3); }
  | E TK_L E 	{ $$ = gera_codigo_operacao($1,$2,$3); }
  | E TK_GE E  { $$ = gera_codigo_operacao($1,$2,$3); }
  | E TK_LE E  { $$ = gera_codigo_operacao($1,$2,$3); }
  | E TK_EQ E   { $$ = gera_codigo_operacao($1,$2,$3); }
  | E TK_NEQ E  { $$ = gera_codigo_operacao($1,$2,$3); }
  | E TK_AND E  { $$ = gera_codigo_operacao($1,$2,$3); }
  | E TK_OR E   { $$ = gera_codigo_operacao($1,$2,$3); }
  | TK_NOT E    { $$ = gera_not($2); }
  | V
  ;
  
V : TK_ID '[' E ']' 
        { $$.v = gera_temp();
      $$.c = $3.c + $$.v + " = " + $1.v + "[" + $3.v + "];\n";                    
    }
  | TK_ID     { $$.c = ""; $$.v = $1.v; }
  | CINT      { $$.c = ""; $$.v = $1.v; } 
  | '(' E ')' { $$ = $2; }
  ;

%%

#include "lex.yy.c"


string cabecalho = 
"#include <iostream>\n"
"#include <cstring>\n"
"using namespace std;\n"
"int main() {\n";

string fim_programa = 
"return 0;\n"
"}\n";

void yyerror( const char* st ) {
   puts( st ); 
   printf( "Linha %d, coluna %d, proximo a: %s\n", linha, coluna, yytext );
   exit( 0 );
}


string gera_temp() {
  static int n_var_temp = 0;
  
  string nome = "t_" + to_string( n_var_temp++ );
  ts[nome] = "  int " + nome + ";\n";
  
  return nome;
}

string gera_label(){
	static int label = 0;

	char buf[20] = "";
	sprintf(buf, "label%d", label++ );
	return buf;
}

string declara_variaveis() {
  string saida;
  
  for( auto p : ts ) 
    saida += p.second;
  
  return saida;
}

void gera_programa( Atributos a ) {
  cout << cabecalho 
       << declara_variaveis()
       << a.c
       << fim_programa
       << endl;
}

Atributos gera_codigo_atribuicao( Atributos lvalue, Atributos rvalue ) {
  Atributos gerado;
  
  ts[lvalue.v] = "  int " + lvalue.v + ";\n";
  gerado.v = lvalue.v;
  gerado.c = lvalue.c + rvalue.c + 
             "  " + gerado.v + " = " + rvalue.v + ";\n";
  
  return gerado;
}

Atributos gera_not( Atributos param ) {
  Atributos gerado;
  
  gerado.v = gera_temp();
  gerado.c = param.c + gerado.v + " = !" + param.v + ";\n";
  
  return gerado;
}

Atributos gera_codigo_operacao( Atributos param1, Atributos opr, Atributos
param2 ) {
  Atributos gerado;
  
  gerado.v = gera_temp();
  gerado.c = param1.c + param2.c + 
             "  " + gerado.v + " = " + param1.v + opr.v + param2.v + ";\n";
  
  return gerado;
}

int main( int argc, char * st[]) {
	yyparse();

	return 0;
}
