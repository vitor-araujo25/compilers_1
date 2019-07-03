%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>
#include <queue>
#include <utility>

using namespace std;

#define YYSTYPE Atributos

typedef string Tipo;

struct Atributos {
  string v;
  string c;
  Tipo t;
  int linha;
};

extern "C" int yylex();
int yyparse();
void yyerror(const char *);

void geraPrograma(string decl, string code);
string declareVars(Tipo t);
string geraTemp( Tipo t );
string geraLabel();
string declaraTemps();
Atributos geraCodigoOperador( Atributos a, string op, Atributos b );
Atributos geraNot( string op, Atributos a );

int linha = 1;
int coluna = 1;

map<string,Tipo> symbolTable;
map<string,Tipo> resOpr = {
{ "i+i", "i" }, { "i+d", "d" }, { "d+i", "d" }, { "d+d", "d" },
{ "c+c", "s" }, { "c+s", "s" }, { "s+c", "s" }, { "s+s", "s" },
{ "c+i", "i" }, { "i+c", "i" },
{ "i-i", "i" }, { "i-d", "d" }, { "d-i", "d" }, { "d-d", "d" },
{ "c-c", "c" }, { "c-i", "i" }, { "i-c", "i" },
{ "i*i", "i" }, { "i*d", "d" }, { "d*i", "d" }, { "d*d", "d" },
{ "c*c", "c" }, { "c*i", "i" }, { "i*c", "i" },
{ "i/i", "i" }, { "i/d", "d" }, { "d/i", "d" }, { "d/d", "d" },
{ "c/c", "c" }, { "c/i", "i" }, { "i/c", "i" },
{ "i\%i", "i" },
{ "i!i", "i" }, { "c!c", "i" },
};

map<Tipo, string> conv = {
{ "i", "int" }, { "c", "char" }, { "s", "string" }, { "b", "boolean" },
{ "d", "real"}
};

map<Tipo,int> nVar;
queue<pair<string, string> > declarationQueue;

%}

%start S
%token CINT CREAL CCHAR CSTR 
%token TK_INT TK_REAL TK_STRING TK_BOOLEAN TK_CHAR
%token TK_ID TK_CONSOLE TK_SHIFTR TK_SHIFTL
%token TK_FOR TK_IN TK_2PT TK_IF TK_THEN TK_ELSE TK_ENDL
%token TK_GE TK_LE TK_AND TK_OR TK_NOT TK_EQ TK_NEQ TK_BEGIN TK_END TK_G TK_L
%token TK_TRUE TK_FALSE

%left TK_OR
%left TK_AND
%left TK_EQ TK_NEQ
%left TK_L TK_LE TK_G TK_GE  
%left '+' '-' 
%left '*' '/' '%'
%left TK_NOT

%%

S : DECLVARS CMDS { geraPrograma($1.c,$2.c); }
  ;  

DECLVARS : DECLVARS DECLVAR ';' { $$.c = $1.c + $2.c; }
         | DECLVAR ';' 
         ; 
    
DECLVAR : TK_INT VARS { $$.c = declareVars("i"); }         
          | TK_CHAR VARS { $$.c = declareVars("c"); }
          | TK_STRING VARS { $$.c = declareVars("s"); }
          | TK_BOOLEAN VARS { $$.c = declareVars("i");  }
          | TK_REAL VARS { $$.c = declareVars("d");  }
          ;
    
VARS : VARS ',' VAR { $$.c = $1.c + ", " + $3.c; $1.t = $$.t; }
       | VAR 
       ;
     
VAR : TK_ID '[' CINT ']' 
      {  
        $$.c = $1.v + "[" + $3.v + "]"; $1.t = $$.t; 
        declarationQueue.push(make_pair($1.v, $3.v));
      }
      | TK_ID { $$.c = $1.v; $1.t = $$.t; declarationQueue.push(make_pair($1.v, "")); }
      ;
    

CMDS : CMDS CMD { $$.c = $1.c + $2.c; }
       | CMD
       ;
  
CMD : ENTRADA ';'
      | SAIDA ';'
      | ATR ';'
      | FOR
      | IF
      ;

ENTRADA : TK_CONSOLE TK_SHIFTR REC_E { $$.c = $3.c; }
        ;

REC_E : REC_E TK_SHIFTR TK_ID { $$.c = $1.c + "cin >> " + $3.v + ";\n"; }
        | REC_E TK_SHIFTR TK_ID '[' E ']' 
        { 
          $$.c = $5.c + $1.c + "cin >> " + $3.v + "[" + $5.v + "]" + ";\n"; ; 
        }
        | TK_ID  { $$.c = "cin >> " + $1.v + ";\n"; }
        | TK_ID '[' E ']' 
        { $$.c = $3.c + "cin >> " + $1.v + "[" + $3.v + "]" + ";\n"; }
      ;
  
SAIDA : TK_CONSOLE TK_SHIFTL REC_S { $$.c = $3.c; }
      ;

REC_S : REC_S TK_SHIFTL CSTR { $$.c = $1.c + "cout << " + $3.v + ";\n"; }
        | REC_S TK_SHIFTL E { $$.c = $3.c + $1.c + "cout << " + $3.v + ";\n"; }
        | REC_S TK_SHIFTL TK_ENDL { $$.c = $3.c + $1.c + "cout << endl;\n"; }
        | CSTR  { $$.c = "cout << " + $1.v + ";\n"; }
        | E { $$.c = $1.c + "cout << " + $1.v + ";\n"; }
        | TK_ENDL { $$.c = $1.c + "cout << endl;\n"; }
      ;
        
FOR : TK_FOR TK_ID TK_IN '[' E TK_2PT E ']' BLOCK
    {  
      string cond = geraTemp("i");  
      symbolTable[cond] = "i";            
      string l1 = geraLabel(), l2 = geraLabel();
      $$.c = $5.c + $7.c 
          + $2.v + " = " + $5.v + ";\n"
          + l1 + ":\n" + cond + " = " + $2.v + " > " + $7.v + ";\n"
          + "if( " + cond + ") goto " + l2 + ";\n"
          + $9.c
          + $2.v + " = " + $2.v + " + 1;\n"
          + "goto " + l1 + ";\n"
          + l2 + ":\n";
    } 
    |  TK_FOR TK_ID TK_IN '[' E TK_2PT E ']' BLOCK ';'
    {  
      string cond = geraTemp("i");
      symbolTable[cond] = "i";       
      string l1 = geraLabel(), l2 = geraLabel();
      $$.c = $5.c + $7.c 
          + $2.v + " = " + $5.v + ";\n"
          + l1 + ":\n" + cond + " = " + $2.v + " > " + $7.v + ";\n"
          + "if( " + cond + ") goto " + l2 + ";\n"
          + $9.c
          + $2.v + " = " + $2.v + " + 1;\n"
          + "goto " + l1 + ";\n"
          + l2 + ":\n";
    }          
    ;
    
%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>
#include <queue>
#include <utility>

using namespace std;

#define YYSTYPE Atributos

typedef string Tipo;

struct Atributos {
  string v;
  string c;
  Tipo t;
  int linha;
};

extern "C" int yylex();
int yyparse();
void yyerror(const char *);

void geraPrograma(string decl, string code);
string declareVars(Tipo t);
string geraTemp( Tipo t );
string geraLabel();
string declaraTemps();
Atributos geraCodigoOperador( Atributos a, string op, Atributos b );
Atributos geraNot( string op, Atributos a );

int linha = 1;
int coluna = 1;

map<string,Tipo> symbolTable;
map<string,Tipo> resOpr = {
{ "i+i", "i" }, { "i+d", "d" }, { "d+i", "d" }, { "d+d", "d" },
{ "c+c", "s" }, { "c+s", "s" }, { "s+c", "s" }, { "s+s", "s" },
{ "c+i", "i" }, { "i+c", "i" },
{ "i-i", "i" }, { "i-d", "d" }, { "d-i", "d" }, { "d-d", "d" },
{ "c-c", "c" }, { "c-i", "i" }, { "i-c", "i" },
{ "i*i", "i" }, { "i*d", "d" }, { "d*i", "d" }, { "d*d", "d" },
{ "c*c", "c" }, { "c*i", "i" }, { "i*c", "i" },
{ "i/i", "i" }, { "i/d", "d" }, { "d/i", "d" }, { "d/d", "d" },
{ "c/c", "c" }, { "c/i", "i" }, { "i/c", "i" },
{ "i\%i", "i" },
{ "i!i", "i" }, { "c!c", "i" },
};

map<Tipo, string> conv = {
{ "i", "int" }, { "c", "char" }, { "s", "string" }, { "b", "boolean" },
{ "d", "real"}
};

map<Tipo,int> nVar;
queue<pair<string, string> > declarationQueue;

%}

%start S
%token CINT CREAL CCHAR CSTR 
%token TK_INT TK_REAL TK_STRING TK_BOOLEAN TK_CHAR
%token TK_ID TK_CONSOLE TK_SHIFTR TK_SHIFTL
%token TK_FOR TK_IN TK_2PT TK_IF TK_THEN TK_ELSE TK_ENDL
%token TK_GE TK_LE TK_AND TK_OR TK_NOT TK_EQ TK_NEQ TK_BEGIN TK_END TK_G TK_L
%token TK_TRUE TK_FALSE

%left TK_OR
%left TK_AND
%left TK_EQ TK_NEQ
%left TK_L TK_LE TK_G TK_GE  
%left '+' '-' 
%left '*' '/' '%'
%left TK_NOT

%%

S : DECLVARS CMDS { geraPrograma($1.c,$2.c); }
  ;  

DECLVARS : DECLVARS DECLVAR ';' { $$.c = $1.c + $2.c; }
         | DECLVAR ';' 
         ; 
    
DECLVAR : TK_INT VARS { $$.c = declareVars("i"); }         
          | TK_CHAR VARS { $$.c = declareVars("c"); }
          | TK_STRING VARS { $$.c = declareVars("s"); }
          | TK_BOOLEAN VARS { $$.c = declareVars("i");  }
          | TK_REAL VARS { $$.c = declareVars("d");  }
          ;
    
VARS : VARS ',' VAR { $$.c = $1.c + ", " + $3.c; $1.t = $$.t; }
       | VAR 
       ;
     
VAR : TK_ID '[' CINT ']' 
      {  
        $$.c = $1.v + "[" + $3.v + "]"; $1.t = $$.t; 
        declarationQueue.push(make_pair($1.v, $3.v));
      }
      | TK_ID { $$.c = $1.v; $1.t = $$.t; declarationQueue.push(make_pair($1.v, "")); }
      ;
    

CMDS : CMDS CMD { $$.c = $1.c + $2.c; }
       | CMD
       ;
  
CMD : ENTRADA ';'
      | SAIDA ';'
      | ATR ';'
      | FOR
      | IF
      ;

ENTRADA : TK_CONSOLE TK_SHIFTR REC_E { $$.c = $3.c; }
        ;

REC_E : REC_E TK_SHIFTR TK_ID { $$.c = $1.c + "cin >> " + $3.v + ";\n"; }
        | REC_E TK_SHIFTR TK_ID '[' E ']' 
        { 
          $$.c = $5.c + $1.c + "cin >> " + $3.v + "[" + $5.v + "]" + ";\n"; ; 
        }
        | TK_ID  { $$.c = "cin >> " + $1.v + ";\n"; }
        | TK_ID '[' E ']' 
        { $$.c = $3.c + "cin >> " + $1.v + "[" + $3.v + "]" + ";\n"; }
      ;
  
SAIDA : TK_CONSOLE TK_SHIFTL REC_S { $$.c = $3.c; }
      ;

REC_S : REC_S TK_SHIFTL CSTR { $$.c = $1.c + "cout << " + $3.v + ";\n"; }
        | REC_S TK_SHIFTL E { $$.c = $3.c + $1.c + "cout << " + $3.v + ";\n"; }
        | REC_S TK_SHIFTL TK_ENDL { $$.c = $3.c + $1.c + "cout << endl;\n"; }
        | CSTR  { $$.c = "cout << " + $1.v + ";\n"; }
        | E { $$.c = $1.c + "cout << " + $1.v + ";\n"; }
        | TK_ENDL { $$.c = $1.c + "cout << endl;\n"; }
      ;
        
FOR : TK_FOR TK_ID TK_IN '[' E TK_2PT E ']' BLOCK
    {  
      string cond = geraTemp("i");  
      symbolTable[cond] = "i";            
      string l1 = geraLabel(), l2 = geraLabel();
      $$.c = $5.c + $7.c 
          + $2.v + " = " + $5.v + ";\n"
          + l1 + ":\n" + cond + " = " + $2.v + " > " + $7.v + ";\n"
          + "if( " + cond + ") goto " + l2 + ";\n"
          + $9.c
          + $2.v + " = " + $2.v + " + 1;\n"
          + "goto " + l1 + ";\n"
          + l2 + ":\n";
    } 
    |  TK_FOR TK_ID TK_IN '[' E TK_2PT E ']' BLOCK ';'
    {  
      string cond = geraTemp("i");
      symbolTable[cond] = "i";       
      string l1 = geraLabel(), l2 = geraLabel();
      $$.c = $5.c + $7.c 
          + $2.v + " = " + $5.v + ";\n"
          + l1 + ":\n" + cond + " = " + $2.v + " > " + $7.v + ";\n"
          + "if( " + cond + ") goto " + l2 + ";\n"
          + $9.c
          + $2.v + " = " + $2.v + " + 1;\n"
          + "goto " + l1 + ";\n"
          + l2 + ":\n";
    }          
    ;
    
IF : TK_IF E TK_THEN BLOCK TK_ELSE BLOCK
    {     
      string l1 = geraLabel(), l2 = geraLabel();  
      $$.c = $2.c + "if (" + $2.v + ") goto " + l1 + ";\n" + $6.c
        + "goto " + l2 + ";\n" + l1 + ":\n" + $4.c + l2 + ":\n";
    }
    | TK_IF E TK_THEN BLOCK TK_ELSE BLOCK ';'
    {     
      string l1 = geraLabel(), l2 = geraLabel();  
      $$.c = $2.c + "if (" + $2.v + ") goto " + l1 + ";\n" + $6.c
        + "goto " + l2 + ";\n" + l1 + ":\n" + $4.c + l2 + ":\n";
    }
    | TK_IF E TK_THEN BLOCK TK_ELSE IF ';'
    {     
      string l1 = geraLabel(), l2 = geraLabel();  
      $$.c = $2.c + "if (" + $2.v + ") goto " + l1 + ";\n" + $6.c
        + "goto " + l2 + ";\n" + l1 + ":\n" + $4.c + l2 + ":\n";
    }
    | TK_IF E TK_THEN BLOCK
    {
       string l1 = geraLabel();  
       $$.c = $2.c + $2.v + " = !" + $2.v + ";\nif (" + $2.v + ") goto " 
       + l1 + ";\n" + $4.c + l1 + ":\n";
    }
    | TK_IF E TK_THEN BLOCK ';'
    {
       string l1 = geraLabel();  
       $$.c = $2.c + $2.v + " = !" + $2.v + ";\nif (" + $2.v + ") goto " 
       + l1 + ";\n" + $4.c + l1 + ":\n";
    }
   ;

BLOCK : TK_BEGIN CMDS TK_END { $$.c = $2.c ; }
      | TK_BEGIN TK_END { $$.c = "\n"; }
      | CMD { $$.c = $1.c; }

ATR : TK_ID '=' E
      { $$.v = $3.v;
        if (symbolTable[$1.v] == "s"){
          $$.c = $3.c + "strcpy(" + $1.v + "," + $3.v + ");\n";
        } else {
          $$.c = $3.c + $1.v + " = " + $3.v + ";\n";
        }
      }
    | TK_ID '[' E ']' '=' E
      { $$.c = $3.c + $6.c 
             + $1.v + "[" + $3.v + "] = " + $6.v + ";\n";
        $$.v = $6.v;
      }
    ;
  
E : E '+' E     { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E '-' E     { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E '*' E     { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E '/' E     { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E TK_L E     { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E TK_G E     { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E '%' E     { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E TK_GE E  { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E TK_LE E  { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E TK_EQ E   { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E TK_NEQ E  { $$ = geraCodigoOperador( $1, "!=", $3); }
  | E TK_AND E  { $$ = geraCodigoOperador( $1, "&&", $3); }
  | E TK_OR E   { $$ = geraCodigoOperador( $1, "||", $3); }
  | TK_NOT E    { $$ = geraNot( "!", $2); }
  | V
  ;
  
V : TK_ID '[' E ']' 
    { 
      $$.v = geraTemp("i");
      $$.c = $3.c + $$.v + " = " + $1.v + "[" + $3.v + "];\n"; 
      $$.t = symbolTable[$1.v];                
    }
  | TK_ID     { $$.c = ""; $$.v = $1.v; $$.t = symbolTable[$1.v]; }
  | CINT      { $$.c = ""; $$.v = $1.v; $$.t = "i"; } 
  | CREAL     { $$.c = ""; $$.v = $1.v; $$.t = "d"; } 
  | CSTR      { $$.c = ""; $$.v = $1.v; $$.t = "s"; } 
  | CCHAR     { $$.c = ""; $$.v = $1.v; $$.t = "c"; } 
  | TK_TRUE   { $$.c = ""; $$.v = "1"; $$.t = "i"; }   
  | TK_FALSE  { $$.c = ""; $$.v = "0"; $$.t = "i"; }     
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

void geraPrograma( string decl, string code ) {
  cout << cabecalho 
       << declaraTemps() 
       << decl 
       << code 
       << fim_programa 
       << endl;
}

void yyerror( const char* st ) {
   puts( st ); 
   printf( "Linha %d, coluna %d, proximo a: %s\n", linha, coluna, yytext );
   exit( 0 );
}

string declareVars(Tipo t){
  string ret = "";
  while (!declarationQueue.empty()){
    pair<string, string> x = declarationQueue.front();
    symbolTable[x.first] = t;

    if (t == "i" || t == "b") ret += "int " + x.first;
    else if (t == "c") ret += "char " + x.first;
    else if (t == "s") ret += "char " + x.first + "[257]";
    else if (t == "d") ret += "double " + x.first;

    ret += ";\n";
    declarationQueue.pop();
  }  
  return ret;
}

Tipo buscaTipoOperacao( Tipo a, string op, Tipo b ) {
  if (op == ">" || op == "<" || op == ">=" || op == "<=" || op == "==" || op == "!="
      || op == "&&" || op == "||" || op == "!" ){
      if (a == b) return "i";
      if (a == "i" && b == "d") return "i";
      if (a == "d" && b == "i") return "i";
      if (a == "i" && b == "c") return "i";
      if (a == "c" && b == "i") return "i";
      if (a == "s" && b == "c") return "i";
      if (a == "c" && b == "s") return "i";
  }
  map<string,Tipo>::iterator tipo = resOpr.find(a+op+b);
  return (tipo != resOpr.end())? tipo->second : "";

}

Atributos geraCodigoOperador( Atributos a, string op, Atributos b ) {
  Atributos r;
  if (a.t.empty()) { a.t = symbolTable[a.v];}
  if (b.t.empty()) { b.t = symbolTable[b.v];}

  r.t = buscaTipoOperacao( a.t, op, b.t );
  if( r.t == "" ) {
    string temp = "Operacao '" + op + "' inválida entre " + conv[a.t] + " e " + conv[b.t]; 
    yyerror( temp.c_str() );
  }
  
  r.c = a.c + b.c;
  r.v = geraTemp( r.t );
  symbolTable[r.v] = r.t;
  
  if ( (a.t == "s" || b.t == "s" || (a.t == "c" && b.t == "c")) && 
  (op == "+" || op == ">" || op == "<" || op == ">=" || op == "<=" || op == "==" || op == "!=")){

    if (op == "+"){
      if (a.t == "c" && b.t == "c"){
        r.c += "strcpy(" + r.v + ", \"  \");\n";
        r.c += r.v + "[0] = " + a.v + ";\n";
        r.c += r.v + "[1] = " + b.v + ";\n"; 
      } else if (a.t == "c" && b.t == "s") {
        r.c += "strcpy(" + r.v + ", \" \");\n";
        r.c += r.v + "[0] = " + a.v + ";\n"; 
        r.c += "strncat(" + r.v + ", " + b.v + ", 256);\n"; 
      } else if (a.t == "s" && b.t == "c") {
        r.c += "strcpy(" + r.v + ", " + a.v + ");\n";
        string novo = geraTemp( "i" );
        symbolTable[novo] = "i";
        r.c += novo = "strlen(" + r.v + ");\n";
        r.c += novo = novo + " + 1;\n";
        r.c += r.v + "[" + novo + ")] = " + b.v + ";\n"; 
      } else {
        string novo = geraTemp( "i" );
        symbolTable[novo] = "i";
        r.c += "strcpy(" + r.v + "," + a.v + ");\n";
        r.c += "strncat(" + r.v + ", " + b.v + ", 256);\n"; 
      }
    } else {
      
      string v1 = a.v, v2 = b.v;

      if (a.t == "c"){
        string novo = geraTemp( "s" );
        symbolTable[novo] = "s";
        r.c += novo + "[0] = " + a.v + ";\n";
        v1 = novo;
      }

      if (b.t == "c"){
        string novo = geraTemp( "s" );
        symbolTable[novo] = "s";
        r.c += novo + "[0] = " + b.v + ";\n";
        v2 = novo;
      }

      string novo = geraTemp( "i" );
      symbolTable[novo] = "i";
      r.c += novo + " = strcmp(" + v1 + "," + v2 + ");\n";

      if (op == ">"){
        r.c += r.v + " = " + novo + " > 0;\n";
      } else if (op == "<") {
        r.c += r.v + " = " + novo + " < 0 ;\n";
      } else if (op == "==") {
        r.c += r.v + " = " + novo + " == 0;\n";
      } else if (op == "!=") {
        r.c += r.v + " = " + novo + " != 0;\n";
      } else if (op == ">=") {
        r.c += r.v + " = " + novo + " >= 0;\n";
      } else if (op == "<=") {
        r.c += r.v + " = " + novo + " <= 0;\n";
      } 
    }

  } else {
    r.c +=  r.v + " = " + a.v + op + b.v + ";\n";
  }

  return r;
}

Atributos geraNot( string op, Atributos a ) {
  Atributos gerado;
  
  gerado.t = buscaTipoOperacao( a.t, op, a.t );
  if( gerado.t == "" ) {
    string temp = "Operacao '" + op + "' inválida para " + a.t; 
    yyerror( temp.c_str() );
  }
  
  gerado.v = geraTemp( gerado.t );
  gerado.c = a.c + gerado.v + " = !" + a.v + ";\n";
  return gerado;
}

string geraTemp( Tipo t ) {
  return "t_" + t + "_" + to_string( nVar[t]++ );
}

string geraLabel(){
	static int label = 0;

	char buf[20] = "";
	sprintf(buf, "label%d", label++ );
	return buf;
}

string declaraTemps() {
  string res;

  for( auto p : nVar ) 
    for( int i = 0; i < p.second; i ++ ) {

      string nomeTipo;
      if( p.first == "i")
        nomeTipo = "int";
      else if( p.first == "d" )
        nomeTipo = "double";
      else if( p.first == "c" || p.first == "s" )
        nomeTipo = "char";
        
      string aux = "";
      if (p.first == "s") aux = "[257]";

      res += nomeTipo + " t_" + p.first + "_" + to_string( i ) + aux + ";\n";

     }

  return res;
}

int main( int argc, char * st[]) {
	yyparse();

	return 0;
}


ATR : TK_ID '=' E
      { $$.v = $3.v;
        if (symbolTable[$1.v] == "s"){
          $$.c = $3.c + "strcpy(" + $1.v + "," + $3.v + ");\n";
        } else {
          $$.c = $3.c + $1.v + " = " + $3.v + ";\n";
        }
      }
    | TK_ID '[' E ']' '=' E
      { $$.c = $3.c + $6.c 
             + $1.v + "[" + $3.v + "] = " + $6.v + ";\n";
        $$.v = $6.v;
      }
    ;
  
E : E '+' E     { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E '-' E     { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E '*' E     { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E '/' E     { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E TK_L E     { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E TK_G E     { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E '%' E     { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E TK_GE E  { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E TK_LE E  { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E TK_EQ E   { $$ = geraCodigoOperador( $1, $2.v, $3); }
  | E TK_NEQ E  { $$ = geraCodigoOperador( $1, "!=", $3); }
  | E TK_AND E  { $$ = geraCodigoOperador( $1, "&&", $3); }
  | E TK_OR E   { $$ = geraCodigoOperador( $1, "||", $3); }
  | TK_NOT E    { $$ = geraNot( "!", $2); }
  | V
  ;
  
V : TK_ID '[' E ']' 
    { 
      $$.v = geraTemp("i");
      $$.c = $3.c + $$.v + " = " + $1.v + "[" + $3.v + "];\n"; 
      $$.t = symbolTable[$1.v];                
    }
  | TK_ID     { $$.c = ""; $$.v = $1.v; $$.t = symbolTable[$1.v]; }
  | CINT      { $$.c = ""; $$.v = $1.v; $$.t = "i"; } 
  | CREAL     { $$.c = ""; $$.v = $1.v; $$.t = "d"; } 
  | CSTR      { $$.c = ""; $$.v = $1.v; $$.t = "s"; } 
  | CCHAR     { $$.c = ""; $$.v = $1.v; $$.t = "c"; } 
  | TK_TRUE   { $$.c = ""; $$.v = "1"; $$.t = "i"; }   
  | TK_FALSE  { $$.c = ""; $$.v = "0"; $$.t = "i"; }     
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

void geraPrograma( string decl, string code ) {
  cout << cabecalho 
       << declaraTemps() 
       << decl 
       << code 
       << fim_programa 
       << endl;
}

void yyerror( const char* st ) {
   puts( st ); 
   printf( "Linha %d, coluna %d, proximo a: %s\n", linha, coluna, yytext );
   exit( 0 );
}

string declareVars(Tipo t){
  string ret = "";
  while (!declarationQueue.empty()){
    pair<string, string> x = declarationQueue.front();
    symbolTable[x.first] = t;

    if (t == "i" || t == "b") ret += "int " + x.first;
    else if (t == "c") ret += "char " + x.first;
    else if (t == "s") ret += "char " + x.first + "[257]";
    else if (t == "d") ret += "double " + x.first;

    ret += ";\n";
    declarationQueue.pop();
  }  
  return ret;
}

Tipo buscaTipoOperacao( Tipo a, string op, Tipo b ) {
  if (op == ">" || op == "<" || op == ">=" || op == "<=" || op == "==" || op == "!="
      || op == "&&" || op == "||" || op == "!" ){
      if (a == b) return "i";
      if (a == "i" && b == "d") return "i";
      if (a == "d" && b == "i") return "i";
      if (a == "i" && b == "c") return "i";
      if (a == "c" && b == "i") return "i";
      if (a == "s" && b == "c") return "i";
      if (a == "c" && b == "s") return "i";
  }
  map<string,Tipo>::iterator tipo = resOpr.find(a+op+b);
  return (tipo != resOpr.end())? tipo->second : "";

}

Atributos geraCodigoOperador( Atributos a, string op, Atributos b ) {
  Atributos r;
  if (a.t.empty()) { a.t = symbolTable[a.v];}
  if (b.t.empty()) { b.t = symbolTable[b.v];}

  r.t = buscaTipoOperacao( a.t, op, b.t );
  if( r.t == "" ) {
    string temp = "Operacao '" + op + "' inválida entre " + conv[a.t] + " e " + conv[b.t]; 
    yyerror( temp.c_str() );
  }
  
  r.c = a.c + b.c;
  r.v = geraTemp( r.t );
  symbolTable[r.v] = r.t;
  
  if ( (a.t == "s" || b.t == "s" || (a.t == "c" && b.t == "c")) && 
  (op == "+" || op == ">" || op == "<" || op == ">=" || op == "<=" || op == "==" || op == "!=")){

    if (op == "+"){
      if (a.t == "c" && b.t == "c"){
        r.c += "strcpy(" + r.v + ", \"  \");\n";
        r.c += r.v + "[0] = " + a.v + ";\n";
        r.c += r.v + "[1] = " + b.v + ";\n"; 
      } else if (a.t == "c" && b.t == "s") {
        r.c += "strcpy(" + r.v + ", \" \");\n";
        r.c += r.v + "[0] = " + a.v + ";\n"; 
        r.c += "strncat(" + r.v + ", " + b.v + ", 256);\n"; 
      } else if (a.t == "s" && b.t == "c") {
        r.c += "strcpy(" + r.v + ", " + a.v + ");\n";
        string novo = geraTemp( "i" );
        symbolTable[novo] = "i";
        r.c += novo = "strlen(" + r.v + ");\n";
        r.c += novo = novo + " + 1;\n";
        r.c += r.v + "[" + novo + ")] = " + b.v + ";\n"; 
      } else {
        string novo = geraTemp( "i" );
        symbolTable[novo] = "i";
        r.c += "strcpy(" + r.v + "," + a.v + ");\n";
        r.c += "strncat(" + r.v + ", " + b.v + ", 256);\n"; 
      }
    } else {
      
      string v1 = a.v, v2 = b.v;

      if (a.t == "c"){
        string novo = geraTemp( "s" );
        symbolTable[novo] = "s";
        r.c += novo + "[0] = " + a.v + ";\n";
        v1 = novo;
      }

      if (b.t == "c"){
        string novo = geraTemp( "s" );
        symbolTable[novo] = "s";
        r.c += novo + "[0] = " + b.v + ";\n";
        v2 = novo;
      }

      string novo = geraTemp( "i" );
      symbolTable[novo] = "i";
      r.c += novo + " = strcmp(" + v1 + "," + v2 + ");\n";

      if (op == ">"){
        r.c += r.v + " = " + novo + " > 0;\n";
      } else if (op == "<") {
        r.c += r.v + " = " + novo + " < 0 ;\n";
      } else if (op == "==") {
        r.c += r.v + " = " + novo + " == 0;\n";
      } else if (op == "!=") {
        r.c += r.v + " = " + novo + " != 0;\n";
      } else if (op == ">=") {
        r.c += r.v + " = " + novo + " >= 0;\n";
      } else if (op == "<=") {
        r.c += r.v + " = " + novo + " <= 0;\n";
      } 
    }

  } else {
    r.c +=  r.v + " = " + a.v + op + b.v + ";\n";
  }

  return r;
}

Atributos geraNot( string op, Atributos a ) {
  Atributos gerado;
  
  gerado.t = buscaTipoOperacao( a.t, op, a.t );
  if( gerado.t == "" ) {
    string temp = "Operacao '" + op + "' inválida para " + a.t; 
    yyerror( temp.c_str() );
  }
  
  gerado.v = geraTemp( gerado.t );
  gerado.c = a.c + gerado.v + " = !" + a.v + ";\n";
  return gerado;
}

string geraTemp( Tipo t ) {
  return "t_" + t + "_" + to_string( nVar[t]++ );
}

string geraLabel(){
	static int label = 0;

	char buf[20] = "";
	sprintf(buf, "label%d", label++ );
	return buf;
}

string declaraTemps() {
  string res;

  for( auto p : nVar ) 
    for( int i = 0; i < p.second; i ++ ) {

      string nomeTipo;
      if( p.first == "i")
        nomeTipo = "int";
      else if( p.first == "d" )
        nomeTipo = "double";
      else if( p.first == "c" || p.first == "s" )
        nomeTipo = "char";
        
      string aux = "";
      if (p.first == "s") aux = "[257]";

      res += nomeTipo + " t_" + p.first + "_" + to_string( i ) + aux + ";\n";

     }

  return res;
}

int main( int argc, char * st[]) {
	yyparse();

	return 0;
}
