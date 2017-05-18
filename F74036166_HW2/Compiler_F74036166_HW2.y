 /************************Definition***********************/

 /*****************C code*************/
%{
    #include <stdio.h>
    #include <ctype.h>
    #include <stdlib.h>
    #include <string.h>

    #define RED "\x1b[31m"
    #define ORIGIN "\x1b[0m" 

    void yyerror(char *);
    void create_symbol();
    void insert_symbol(char *id, char *type, int data);
    void symbol_assign(char *id, int data);
    int lookup_symbol(char *id);
    void dump_symbol();


    extern int yylineno;
    extern int yylex();

    int sym_num;            //number of symbol
    bool is_err = false;    //is there error
    char error_msg[100];    //error message

%}

 /************token definition********/
%token SEM PRINT WHILE INT DOUBLE LB RB
%token STRING ADD SUB MUL DIV
%token ASSIGN NUMBER FLOATNUM ID

 /***********type definition**********/
%union{
    double double_val;
    int int_val;
    char str[100];
}

 /**********type declaration**********/
%type<double_val> FLOATNUM;
%type<int_val> NUMBER;
%type<str> STRING ID;

%%

 /****************grammar rule and action******************/
lines
    : {}
    | lines Stmt {};

 /*define statement type Declaration, Assign, Print, Arithmetic and Branch*/
Stmt
    :   Decl SEM {if(!is_err)$$=$1; is_err=false;}
    |   Assign SEM {if(!is_err)$$=$1; is_err=false;}
    |   Print SEM {if(!is_err)$$=$1; is_err=false;}
    |   Arith SEM {if(!is_err)$$=$1; is_err=false;};

Decl
    :   Type ID 
        {
            if(!is_err)
            {
                if()
                {
                    yyerror();
                }
                else
                {
                    insert_symbol();
                }
            }
        }
    |   Type ID ASSIGN Arith
        {
            if(!is_err)
            {
                if()
                {
                    yyerror();
                }
                else
                {
                    insert_symbol();
                    symbol_assign();
                }
            }
        };

Type
    :   INT {if(!is_err)strcpy($$, "int");}
    |   DOUBLE{if(!is_err)strcpy($$, "double");};

Assign
    :   ID ASSIGN Arith
        {
            if(!is_err)
            {
                printf("ASSIGN\n");
                if()
                {
                    yyerror();
                }
                else
                {
                    symbol_assign();
                }
            }
        };

Arith
    :   Rhs{if(!is_err)$$=$1;}
    |   Arith ADD Rhs
        {
            if(!is_err)
            {
                printf("ADD\n");
                $$ = $1 + $3;
            }
        }
    |   Arith SUB Rhs
        {
            if(!is_err)
            {
                printf("SUB\n");
                $$ = $1 - $3;
            }
        }

Rhs
    :   Term{if(!is_err)$$=$1;}
    |   Rhs MUL Term
        {
            if(!is_err)
            {
                printf("MUL\n");
                $$ = $1 * $3;
            }
        }
    |   Rhs DIV Term
        {
            if(!is_err)
            {
                if($3==0)
                {
                    yyerror();
                }
                else
                {
                    printf("DIV\n");
                    $$ = $1 / $3;
                }
            }
        };

Term
    :   Paratheses{if(!is_err)$$=$1;}
    |   NUMBER{if(!is_err)$$=$1;}
    |   FLOATNUM{if(!is_err)$$=$1;}
    |   ID
        {
            double temp;
            if(!is_err)
            {
                temp = lookup_symbol();
                if(temp==-1)
                {
                    yyerror();
                }
                else
                {
                    $$ = temp;
                }
            }
        };

Print
    :   PRINT Paratheses{if(!is_err)printf("Print : %g\n", $2);}
    |   PRINT LB STRING RB{if(!is_err)printf("Print : %s\n", $3);};

Paratheses
    :   LB Arith RB{if(!is_err)$$=$2;};

%%

 /*******************Auxiliary procedures******************/

int main(int argc, char *argv[])
{
    yylineno = 0;
    sym_num = 0;
    create_symbol();
    yyparse();


    printf("Total lines: %d\n\n", yylineno);
    dump_symbol();
    
    return 0;
}

void yyerror(char *s)
{
    printf(RED);
    printf("<ERROR> %s (line %d)", s, yylineno);
    printf(ORIGIN);
    is_err = true;
}



