%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <map>

extern "C" int yylex();


using namespace std;

int token;
string lexema;

void A();
void E();
void E_linha();
void F();
void T();
void T_linha();
void casa( int );

enum { tk_int = 256, tk_double, tk_id, tk_string, tk_print };

map<int,string> nome_tokens = {
  { tk_int, "int" },
  { tk_double, "double" },
  { tk_id, "nome de identificador" },
  { tk_string, "string" },
  { tk_print, "print"}
};

%}

WS  [ \n\t]
DIGITO  [0-9]
LETRA [A-Za-z_]

NUM {DIGITO}+
ID  {LETRA}({LETRA}|{DIGITO})*
DOUBLE {NUM}(\.{NUM})?([Ee][+-]?{NUM})?
STR \"([^\"\n\t\r]|\\\"|\ |\"\")*\" 


%%

{WS}      { }
{STR}     { lexema = yytext; return tk_string; }
{NUM}     { lexema = yytext; return tk_int; }
{DOUBLE}  { lexema = yytext; return tk_double;}
"print"   { return tk_print;}
{ID}    { lexema = yytext; return tk_id; }

.   { return yytext[0]; }

%%

int next_token() {
  return yylex();
}

string nome_token( int token ) {
  if( nome_tokens.find( token ) != nome_tokens.end() )
    return nome_tokens[token];
  else {
    string r;
    
    r = token;
    return r;
  }
}

void A() {
  switch (token){
    case tk_print: 
      casa ( tk_print ); F(); cout << endl; break;
    default: 
      casa( tk_id ); cout << lexema << " "; casa( '=' ); E(); cout << "=" << " "; casa( ';'); cout << endl;
  }

}

void E() {
  T();
  E_linha();
}

void E_linha() {
  switch( token ) {
    case '+' : casa( '+' ); T(); cout << "+" << " "; E_linha(); break;
    case '-' : casa( '-' ); T(); cout << "-" << " "; E_linha(); break;
  }
}

void T() {
  F();
  T_linha();
}

void T_linha() {
  switch( token ) {
    case '*' : casa( '*' ); F(); cout << "*" << " "; T_linha(); break;
    case '/' : casa( '/' ); F(); cout << "/" << " "; T_linha(); break;
  }
}

void F() {
  switch( token ) {
    case tk_string: casa( tk_string ); cout << lexema << " "; break;
    case tk_id : casa( tk_id ); cout << lexema << " @" << " "; break;
    case tk_int: casa( tk_int ); cout << lexema << " "; break;
    case tk_double: casa(tk_double); cout << lexema << " "; break;
    case '(': casa( '(' ); E(); casa( ')' ); break;
    default:
      cout << "Operando esperado, encontrado " << lexema << endl;
  }
}


void casa( int esperado ) {
    if( token == esperado )
        token = next_token();
    else {
        cout << "Esperado " << nome_token( esperado ) 
        << " , encontrado: " << nome_token( token ) << endl;
        exit( 1 );
    }
}

int main() {
    token = next_token();
    while(token != 0){
        A();
    }
  
    return 0;
}