%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "node.h"
extern int yylineno;
extern int yylex();
int yyerror(char *s);
%}
%union {
	int i;			/* integer value */
	double r;		/* real value */
	char *s;		/* symbol name or string literal */
  Node *n;
};
%token <i> INT
%token <r> REAL
%token <s> ID STR
%token DO WHILE IF THEN FOR IN UPTO DOWNTO STEP BREAK CONTINUE
%token VOID INTEGER STRING NUMBER CONST PUBLIC ELSE

%right THEN ELSE /*TOD perceber esta solucao https://stackoverflow.com/questions/12731922/reforming-the-grammar-to-remove-shift-reduce-conflict-in-if-then-else*/
%right ATR
%left '|'
%left '&'
%nonassoc '~'
%left '=' NE
%left '<' '>' GE LE
%left '+' '-'
%left '*' '/' '%'
%nonassoc '!' INCR DECR /*TODO '-' '&' e '*' sao usados em quer em unitario quer em operacoes de 2 operandos*/
%nonassoc '[' '('

%%

ficheiro: decls
        ;

decls: decls decl
     |
     ;

decl: PUBLIC CONST tipo '*' ID init ';'
    | PUBLIC CONST tipo '*' ID ';'
    | PUBLIC CONST tipo ID init ';'
    | PUBLIC CONST tipo ID ';'
    | PUBLIC tipo '*' ID init ';'
    | PUBLIC tipo '*' ID ';'
    | PUBLIC tipo ID init ';'
    | PUBLIC tipo ID ';'
    | CONST tipo '*' ID init ';'
    | CONST tipo '*' ID ';'
    | CONST tipo ID init ';'
    | CONST tipo ID ';'
    | tipo '*' ID init ';'
    | tipo '*' ID ';'
    | tipo ID init ';'
    | tipo ID ';'
    ;

tipo: INTEGER
    | STRING
    | NUMBER
    | VOID
    ;

init: ATR INT
    | ATR CONST STR
    | ATR STR
    | ATR REAL
    | ATR ID
    | '(' params ')' body 
    | '(' params ')'
    | '(' ')' body
    | '(' ')' 
    ;

params: params ',' param
      | param;

param: tipo '*' ID
     | tipo ID;

body: '{'params2 instrs'}';

params2: params2 param ';'
       |
       ;

instrs: instrs instr
      |
      ;

instr: IF expr THEN instr
     | IF expr THEN instr ELSE instr
     | DO instr WHILE expr ';'
     | FOR INT IN expr UPTO expr STEP expr DO instr
     | FOR INT IN expr DOWNTO expr STEP expr DO instr
     | FOR INT IN expr UPTO expr DO instr
     | FOR INT IN expr DOWNTO expr DO instr {/*TODO ver o que é o left value e substituir o INT se for necessario*/}
     | expr';'
     | body
     | BREAK INT ';'
     | BREAK ';'
     | CONTINUE INT ';'
     | CONTINUE ';'
     | INT '#' expr ';' {/*TODO ver o que é o left value e substituir o INT se for necessario*/}
     ;

expr: ID
    | lit
    | expr ATR expr
    | expr '|' expr
    | expr '&' expr
    | '~' expr
    | expr '=' expr
    | expr NE expr
    | expr GE expr
    | expr LE expr
    | expr '<' expr
    | expr '>' expr
    | expr '-' expr {/*TODO verificar que as expr sao do tipo real ou interio*/}
    | expr '+' expr {/*TODO verificar que as expr sao do tipo real ou interio*/}
    | expr '%' expr {/*TODO verificar que as expr sao do tipo real ou interio*/}
    | expr '/' expr {/*TODO verificar que as expr sao do tipo real ou interio*/}
    | expr '*' expr {/*TODO verificar que as expr sao do tipo real ou interio*/}
    | expr DECR     {/*TODO verificar que expr e do tipo inteiro*/}
    | expr INCR     {/*TODO verificar que expr e do tipo inteiro*/}
    | DECR expr    {/*TODO verificar que expr e do tipo inteiro TODO sera assim?*/}
    | INCR expr    {/*TODO verificar que expr e do tipo inteiro TODO sera assim?*/}
    | "-" expr
    | expr '!'
    | '&' expr
    | '*' expr
    | '('expr')'
    | ID'['expr']' {/*TODO nao sei se e assim TODO confirmar se e apontador para inteiro*/}
    | ID'('args')' {/*TODO ver se a fhncao foi declarada e com este numero de argumentos*/}
    | ID'(' ')'  {/*TODO nao ha casts implicitos TODO vars e consts do tipo void*/}
    ; 

args: args ',' expr
    | expr
    ;

lit: STR
   | INT
   | REAL
   ;
 
%%
int yyerror(char *s) { fprintf(stderr, "line %d: %s\n", yylineno, s); return 0; }
char *dupstr(const char*s) { return strdup(s); }

int main(int argc, char *argv[]) {

/*  extern YYSTYPE yylval;
 int tk;
 while ((tk = yylex())) 
  if (tk > YYERRCODE)
   printf("%d:\t%s\n", tk, yyname[tk]);
  else
   printf("%d:\t%c\n", tk, tk);
 return 0; */
 yyparse();
}

