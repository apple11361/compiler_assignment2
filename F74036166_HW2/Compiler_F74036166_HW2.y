 /************************Definition***********************/

 /*****************C code*************/
%{
    #include <stdio.h>
    #include <ctype.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>

    #define RED "\x1b[31m"
    #define ORIGIN "\x1b[0m" 

    typedef struct _SYMBOL{
        int index;
        char id[100];
        char type[10];
        double val;
        struct _SYMBOL *list_next;
        struct _SYMBOL *hash_next;
    }symbol;

    void yyerror(char *);
    void create_symbol();
    void insert_symbol(char *s, char *type);
    void symbol_assign(char *sym, double data);
    double lookup_symbol(char *sym);
    void dump_symbol();


    extern int yylineno;
    extern int yylex();
    extern int type_flag;           //declaration in *.l    default:0, int:1, double:2
    extern int pre_type_flag;       //declaration in *.l    default:0, int:1, double:2
    extern int symbol_num;          //number of symbol

    int sym_num;            //number of symbol
    bool is_err = false;    //is there error
    char error_msg[100];    //error message

    symbol *symbol_list_head;   //for dumping
    symbol **symbol_hash;       //for insertion, retrieval
    symbol *temp;

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
%type<double_val> Stmt Decl Assign Arith Term Print Parentheses Rhs FLOATNUM NUMBER;
%type<str> STRING ID Type;

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
                if(lookup_symbol($2)!=-1)
                {
                    sprintf(error_msg, "re-declaration for variable %s", $2);
                    yyerror(error_msg);
                }
                else
                {
                    insert_symbol($2, $1);
                }
            }
        }
    |   Type ID ASSIGN Arith
        {
            if(!is_err)
            {
                if(lookup_symbol($2)!=-1)
                {
                    sprintf(error_msg, "re-declaration for variable %s", $2);
                    yyerror(error_msg);
                }
                else
                {
                    insert_symbol($2, $1);
                    symbol_assign($2, $4);
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
                if(lookup_symbol($1)==-1)
                {
                    sprintf(error_msg, "cannot find the variable %s", $1);
                    yyerror(error_msg);
                }
                else
                {
                    symbol_assign($1, $3);
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
                    sprintf(error_msg, "The divisor can not be 0");
                    yyerror(error_msg);
                }
                else
                {
                    printf("DIV\n");
                    $$ = $1 / $3;
                }
            }
        };

Term
    :   Parentheses{if(!is_err)$$=$1;}
    |   NUMBER{if(!is_err)$$=$1;}
    |   FLOATNUM{if(!is_err)$$=$1;}
    |   ID
        {
            double temp;
            if(!is_err)
            {
                temp = lookup_symbol($1);
                if(temp==-1)
                {
                    sprintf(error_msg, "cannot find the variable %s", $1);
                    yyerror(error_msg);
                }
                else
                {
                    $$ = temp;
                }
            }
        };

Print
    :   PRINT Parentheses{if(!is_err)printf("Print : %g\n", $2);}
    |   PRINT LB STRING RB{if(!is_err)printf("Print : %s\n", $3);};

Parentheses
    :   LB Arith RB{if(!is_err)$$=$2;};

%%

 /*******************Auxiliary procedures******************/

int main(int argc, char *argv[])
{
    yylineno = 1;
    sym_num = 0;
    create_symbol();
    yyparse();


    printf("\nTotal lines: %d\n\n", yylineno);
    dump_symbol();
    
    return 0;
}

void yyerror(char *s)
{
    printf(RED);
    printf("<ERROR> %s (line %d)\n", s, yylineno);
    printf(ORIGIN);
    is_err = true;
}

void create_symbol()
{
    symbol_hash = (symbol **)malloc(sizeof(symbol *)*26);
    printf("Create symbol table\n\n");
}

void insert_symbol(char *s, char *type)
{
    temp = (symbol *)malloc(sizeof(symbol));
    temp->index = symbol_num++;
    strcpy(temp->id, s);
    strcpy(temp->type, type);
    temp->val = 0;

    if(!symbol_list_head)
    {
        symbol_list_head = temp;
    }
    else
    {
        symbol* i;
        for(i=symbol_list_head;i->list_next;i=i->list_next);
        i->list_next = temp;
    }
    if('a'<=s[0]<='z')
    {
        if(!symbol_hash[s[0]-'a'])
        {
            symbol_hash[s[0]-'a'] = temp;
        }
        else
        {
            temp->hash_next = symbol_hash[s[0]-'a'];
            symbol_hash[s[0]='a'] = temp;
        }
    }
    else
    {
        if(!symbol_hash[s[0]-'A'])
        {
            symbol_hash[s[0]-'A'] = temp;
        }
        else
        {
            temp->hash_next = symbol_hash[s[0]-'A'];
            symbol_hash[s[0]='A'] = temp;
        }
    }
    printf("Insert symbol: %s\n", s);
}

double lookup_symbol(char *sym)
{
    if('a'<=sym[0] && sym[0]<='z')
    {
        if(!symbol_hash[sym[0]-'a'])
        {
            return -1;
        }
        else
        {
            symbol *i;
            for(i=symbol_hash[sym[0]-'a'];i!=NULL;i=i->hash_next)
            {
                if(!strcmp(sym, i->id))
                {
                    return i->val;
                }
            }
            return -1;
        }
    }
    else
    {
        if(!symbol_hash[sym[0]-'A'])
        {
            return -1;
        }
        else
        {
            symbol *i;
            for(i=symbol_hash[sym[0]-'A'];i!=NULL;i=i->hash_next)
            {
                if(!strcmp(sym, i->id))
                {
                    return i->val;
                }
            }
            return -1;
        }
    }
}

void dump_symbol()
{
    printf("The symbol table :\n\n");
    printf("ID\t\tType\t\tData\n");
    while(symbol_list_head)
    {
        printf("%s\t\t%s\t\t%g\n", symbol_list_head->id, symbol_list_head->type, symbol_list_head->val);

        symbol_list_head = symbol_list_head->list_next;
    }
}

void symbol_assign(char *sym, double data)
{
    if('a'<=sym[0]<='z')
    {
        symbol *i;
        for(i=symbol_hash[sym[0]-'a'];i!=NULL;i=i->hash_next)
        {
            if(!strcmp(sym, i->id))
            {
                i->val = data;
                return;
            }
        }
    }
    else
    {
        symbol *i;
        for(i=symbol_hash[sym[0]-'A'];i!=NULL;i=i->hash_next)
        {
            if(!strcmp(sym, i->id))
            {
                i->val = data;
                return;
            }
        }
    }
}




