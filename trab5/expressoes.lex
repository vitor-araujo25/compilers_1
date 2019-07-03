%{
int token( int );
%}
DIGITO  [0-9]
LETRA   [A-Za-z_]
INT     {DIGITO}+
REAL    {DIGITO}+("."{DIGITO}+)?
ID      {LETRA}({LETRA}|{DIGITO})*
STR     (\"([^"]|\\\")*\")
CHAR    (\'.\')

%%

"\t"       { coluna += 4; }
" "        { coluna++; }
"\n"	   { linha++; coluna = 1; }

{INT} 	   { return token( CINT ); }
{REAL}     { return token( CREAL ); }
{STR}      { return token( CSTR ); }
{CHAR}     { return token( CCHAR ); }

"boolean"  { return token( TK_BOOLEAN ); }
"int"      { return token( TK_INT ); }
"real"     { return token( TK_REAL ); }
"string"   { return token( TK_STRING ); }
"char"     { return token( TK_CHAR ); }

"console"  { return token( TK_CONSOLE ); }
">>"       { return token( TK_SHIFTR ); }
"<<"       { return token( TK_SHIFTL ); }
"for"      { return token( TK_FOR ); }
"in"       { return token( TK_IN ); }
".."       { return token( TK_2PT ); }
"if"       { return token( TK_IF ); }
"then"     { return token( TK_THEN ); }
"else"     { return token( TK_ELSE ); }
">="       { return token( TK_GE ); }      
"<="       { return token( TK_LE ); }    
"=="       { return token( TK_EQ ); }  
"<>"       { return token( TK_NEQ ); }
"<"         { return token( TK_L );}
">"         { return token( TK_G );}
"or"       { return token( TK_OR ); }
"and"      { return token( TK_AND ); }
"not"      { return token( TK_NOT ); }
"endl"     { return token( TK_ENDL); }
"begin"    { return token( TK_BEGIN ); }
"end"      { return token( TK_END ); }
"true"     { return token( TK_TRUE ); }
"false"    { return token( TK_FALSE ); }

{ID}       { return token( TK_ID ); }

.          { return token( *yytext ); }

%%

int token( int tk ) {
 yylval.v = yytext; 
 coluna += strlen(yytext); 
 return tk;
}

int yywrap (void) {return 1;}