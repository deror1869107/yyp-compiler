%{
#define LIST               strcat(buf, yytext)
#define token(t)           {LIST; if (Opt_T) printf("<%s>\n", #t);}
#define tokenChar(t)       {LIST; if (Opt_T) printf("<%c>\n", (t));}
#define tokenInteger(t, i) {LIST; if (Opt_T) printf("<%s: %d>\n", #t, (i));}
#define tokenString(t, s)  {LIST; if (Opt_T) printf("<%s: %s>\n", #t, (s));}
#define tokenKeyword(t)    {LIST; if (Opt_T) printf("<KW%s>\n", (t));}
#define tokenStr(t)        {LIST; if (Opt_T) printf("<%s>\n", (t));}
#define MAX_LINE_LENG      256

int Opt_S = 1;
int Opt_T = 1;
int linenum = 1;
char buf[MAX_LINE_LENG];
char string_buf[MAX_LINE_LENG];
%}

delimiter [,;:\(\)\[\]]
operation (\+)|(\-)|(\*)|(\/)|mod|:=|<|<=|<>|>=|>|=|and|or|not
keyword array|begin|boolean|def|do|else|end|false|for|integer|if|of|print|read|real|string|then|to|true|return|var|while
digit   [0-9]
letter  [a-zA-Z]
identifier  {letter}({letter}|{digit})*
integer (0|[1-9]{digit}*)
octal_integer   0[0-7]+
float   0*{integer}\.{digit}+
scientific  (0*{integer}|{float})[eE][+-]?0*{integer}
string \"([^"\n]*\"{2})*[^"\n]*\"
space   [ \t]+

%x CCOMMENT

%%
  /* c-style comments */
"/*"    { LIST; BEGIN CCOMMENT; }
<CCOMMENT>.     { LIST; }
<CCOMMENT>"*/"  { LIST; BEGIN INITIAL; }
  /* c++-style comments */
"//&S+".*   { LIST; Opt_S = 1; }
"//&S-".*   { LIST; Opt_S = 0; }
"//&T+".*   { LIST; Opt_T = 1; }
"//&T-".*   { LIST; Opt_T = 0; }
"//".*  { LIST; }
  /* delimiters */
{delimiter}     { tokenStr(yytext) }
  /* operations */
{operation}     { tokenStr(yytext) }
  /* keywords */
{keyword}   { tokenKeyword(yytext) }
  /* identifier */
{identifier}    { tokenString(id, yytext) }
  /* integer constants */
{integer}   { tokenString(integer, yytext) }
{octal_integer} { tokenString(oct_integer, yytext) }
  /* floating-point constants */
{float} { tokenString(float, yytext) }
  /* scientific notations */
{scientific}    { tokenString(scientific, yytext) }
  /* string constants */
{string}    {
              int len = 0;
              for(int i = 1; i < yyleng - 1; ++i){
                string_buf[len++] = yytext[i];
                if(yytext[i] == '\"' && yytext[i + 1] == '\"') ++i;
              }
              string_buf[len] = '\0';
              tokenString(string, string_buf);
            }
  /* whitespaces */
{space} { LIST; }
  /* invalid input */
.       {
          printf("error at line %d: bad character \"%s\"\n",linenum,yytext);
          exit(0);
        }
<INITIAL,CCOMMENT>\n    {
          //LIST;
          if (Opt_S)
            printf("%d: %s\n", linenum, buf);
          linenum++;
          buf[0] = '\0';
        }
%%
int main( int argc, char **argv )
{
  if( argc != 2 ) {
    fprintf( stderr, "Usage: ./scanner [filename]\n" );
    exit(0);
  }
	
  FILE *fp = fopen( argv[1], "r" );
  if( fp == NULL ) {
    fprintf( stderr, "Open file error\n" );
    exit(-1);
  }
	
  yyin = fp;

  yylex();

  exit(0);
}

