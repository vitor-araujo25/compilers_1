%{
int token( int );
%}
DIGITO  [0-9]
LETRA   [A-Za-z_]
INT     {DIGITO}+
DOUBLE  {DIGITO}+("."{DIGITO}+)?
ID      {LETRA}({LETRA}|{DIGITO})*
STR		(\"([^"]|\\\")*\")

%%

"\t"       { coluna += 4; }
" "        { coluna++; }
"\n"	   { linha++; coluna = 1; }
{INT} 	   { return token( CINT ); }
{DOUBLE}   { return token( CDOUBLE ); }
"var"	   { return token( TK_VAR ); }
"console"  { return token( TK_CONSOLE ); }
">>"       { return token( TK_SHIFTR ); }
"<<"       { return token( TK_SHIFTL ); }
">"		    { return token(TK_G); }
"<"		    { return token(TK_L); }
"!"		    { return token(TK_NOT); }
"!="	    { return token(TK_NEQ); }
"=="		{ return token(TK_EQ); }
"<="		{ return token(TK_LE); }
">="		{ return token(TK_GE); }
"&&"		{ return token(TK_AND); }
"||"		{ return token(TK_OR); }
"for"      { return token( TK_FOR ); }
"in"       { return token( TK_IN ); }
".."       { return token( TK_2PT ); }
"if"       { return token( TK_IF ); }
"then"     { return token( TK_THEN ); }
"else"     { return token( TK_ELSE ); }
"endl"	   { return token( TK_ENDL ); }
"begin"		{ return token(TK_BEGIN);}
"end"		{ return token(TK_END); }
{STR}		{ return token ( CSTR ); }
{ID}       { return token( TK_ID ); }
.          { return token( *yytext ); }

%%

int token( int tk ) {
 yylval.v = yytext;
 coluna += strlen(yytext);
 yylval.linha = linha;
 yylval.c = "";
 return tk;
}
