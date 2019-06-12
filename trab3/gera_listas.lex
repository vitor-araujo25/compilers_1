%{
int trataLexema( int token );
%}

DIGITO  [0-9]
LETRA   [A-Za-z_]
DOUBLE  {DIGITO}+("."{DIGITO}+)?
ID      {LETRA}({LETRA}|{DIGITO})*
OPR	[(),]

%%

"\t"   { coluna += 4; }
" "    { coluna++; }
"\n"   { linha++; coluna = 1; }


{DOUBLE}|{ID} { return trataLexema( ATOMO ); }
           
{OPR}    { return trataLexema( (int) yytext[0] );  }
            
.        { coluna++; 
           yylval.head = yytext; 
           yyerror( "Caractere inválido!\n" ); }
%% 

int trataLexema( int token ) {
  yylval.head = yytext; 
  coluna += strlen(yytext); 
  
  return token;
}
