
 /*******************Definition*********************/
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <ctype.h>
    #include <string.h>

    typedef struct _SYMBOL{
        int index;
        char ID[100];
        int TYPE;
        struct _SYMBOL *list_next;
        struct _SYMBOL *hash_next;
    }symbol;

    void create_symbol();
    void insert_symbol();
    int lookup_symbol();
    void dump_symbol();

    int type_flag = 0;          //default:0  int:1  double:2
    int pre_type_flag = 0;      //default:0  int:1  double:2
    int line_num = 0;           //the number of line

    int symbol_num = 0;         //number of symbol 
    symbol *symbol_list_head;   //for dumping
    symbol **symbol_hash;       //for insertion, retrieval
    symbol *temp;

%}

%x COMMENT
%x COMMENT2
%x STR

 /***********Regular Expressions***********/
letter      [a-zA-Z]
digit       [0-9]
id          {letter}+({letter}|{digit})*
integer     ([0-9]|-[0-9])+[0-9]*
%%

 /******************Translation rule*******************/
"//"                {printf("========comment start:========\n");BEGIN COMMENT;}
<COMMENT>[^\n]+     {printf("%s", yytext);}
<COMMENT>\n         {printf("\n========comment end========\n");line_num++;BEGIN INITIAL;}

"/*"                {printf("========comment start:========\n");BEGIN COMMENT2;}
<COMMENT2>.         {printf("%s", yytext);}
<COMMENT2>"*/"      {printf("\n========comment end========\n");BEGIN INITIAL;}
<COMMENT2>\n        {printf("%s", yytext);line_num++;}

"\""                {printf("\"\t\tQUOTATION\n");BEGIN STR;}
<STR>"\\"           ;
<STR>"\\\""         {printf("\"");}
<STR>"\\\\"         {printf("\\");}
<STR>"\\n"          {printf("\n");}
<STR>"\\a"          {printf("\a");}
<STR>"\\b"          {printf("\b");}
<STR>"\\f"          {printf("\f");}
<STR>"\\r"          {printf("\r");}
<STR>"\\t"          {printf("\t");}
<STR>"\\v"          {printf("\v");}
<STR>"\\\?"         {printf("\?");}
<STR>"\\\'"         {printf("\'");}
<STR>"\""           {printf("\t\tSTRING CONSTANT\n\"\t\tQUOTATION\n");BEGIN INITIAL;}
<STR>.              {printf("%s", yytext);}

 /****Constant****/
{digit}+            {printf("%s\t\tNUMBER\n", yytext);}
{digit}*"."{digit}+ {printf("%s\t\tFLOATNUMBER\n", yytext);}

 /****Delimiters****/
";"             {
                    printf("%s\t\tSEMICOLON\n", yytext);
                    type_flag = 0;
                    pre_type_flag = 0;
                }
","             {
                    printf("%s\t\tCOMMA\n", yytext);
                    type_flag = pre_type_flag;
                }
"("             {printf("%s\t\tLB\n", yytext);}
")"             {printf("%s\t\tRB\n", yytext);}
"{"             {printf("%s\t\tLB\n", yytext);}
"}"             {printf("%s\t\tRB\n", yytext);}
"["             {printf("%s\t\tLB\n", yytext);}
"]"             {printf("%s\t\tRB\n", yytext);}
"\n"            {line_num++;}
" "             {}
"\t"            {}

 /****Operators****/
"+"             {printf("%s\t\tOPERATOR\n", yytext);}
"-"             {printf("%s\t\tOPERATOR\n", yytext);}
"*"             {printf("%s\t\tOPERATOR\n", yytext);}
"/"             {printf("%s\t\tOPERATOR\n", yytext);}
"^"             {printf("%s\t\tOPERATOR\n", yytext);}
"%"             {printf("%s\t\tOPERATOR\n", yytext);}
"<"             {printf("%s\t\tRELATIONAL\n", yytext);}
"<="            {printf("%s\t\tRELATIONAL\n", yytext);}
"=="            {printf("%s\t\tRELATIONAL\n", yytext);}
"!="            {printf("%s\t\tRELATIONAL\n", yytext);}
">="            {printf("%s\t\tRELATIONAL\n", yytext);}
">"             {printf("%s\t\tRELATIONAL\n", yytext);}
"="             {
                    printf("%s\t\tASSIGN\n", yytext);
                    type_flag = 0;
                }

 /****Keywords****/
 /*case-insensitive*/
(?i:int)        {type_flag = 1;pre_type_flag = 1;}
(?i:double)     {type_flag = 2;pre_type_flag = 2;}
(?i:print)      {printf("%s\t\tPRINT FUNCTION\n", yytext);}
(?i:if)         {printf("%s\t\tIF FUNCTION\n", yytext);}
(?i:else)       {printf("%s\t\tELSE FUNCTION\n", yytext);}
(?i:while)      {printf("%s\t\tWHILE FUNCTION\n", yytext);}

 /****Identifiers****/
{id}            {
                    if(!type_flag)
                        printf("%s\t\tID\n", yytext);
                    else if(type_flag==1)
                    {
                        printf("%s\t\tint TYPE VAR\n", yytext);
                        if(!symbol_list_head)
                            create_symbol();
                        insert_symbol(yytext);
                    }
                    else if(type_flag==2)
                    {
                        printf("%s\t\tdouble TYPE VAR\n", yytext);
                        if(!symbol_list_head)
                            create_symbol();
                        insert_symbol(yytext);
                    }
                }

.               {;}

%%

 /*****************Auxiliary procedures*****************/
int main(int argc, char *argv[])
{
    yyin = fopen(argv[1], "r");
    yylex();
    return 0;
}

int yywrap(void)
{
    printf("\nParse over, the line number is %d.\n\n", line_num);
    dump_symbol();
    return 1;
}

void create_symbol()
{
    symbol_hash = (symbol **)malloc(sizeof(symbol *)*26);
    printf("Create a symbol table\n");
}

void insert_symbol(char *s)
{
    temp = (symbol *)malloc(sizeof(symbol));
    temp->index = symbol_num++;
    strcpy(temp->ID, s);
    temp->TYPE = type_flag;

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
    printf("Insert a symbol: %s\n", s);
}

int lookup_symbol(char *sym)
{
    if('a'<=sym[0]<='z')
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
                if(!strcmp(sym, i->ID))
                {
                    return sym[0]-'a';
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
                if(!strcmp(sym, i->ID))
                {
                    return sym[0]-'A';
                }
            }
            return -1;
        }
    }
}

void dump_symbol()
{
    printf("The symbol table dump:\n");
    while(symbol_list_head)
    {
        if(symbol_list_head->TYPE==1)
            printf("%d\t%s\t\tint\n", symbol_list_head->index+1, symbol_list_head->ID);
        else
            printf("%d\t%s\t\tdouble\n", symbol_list_head->index+1, symbol_list_head->ID);
        
        symbol_list_head = symbol_list_head->list_next;
    }
}


