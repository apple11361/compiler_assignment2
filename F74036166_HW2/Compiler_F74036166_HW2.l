
 /*******************Definition*********************/
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <ctype.h>
    #include <string.h>
    #include "y.tab.h"

    extern int yylineno;        //the number of line

    int type_flag = 0;          //default:0  int:1  double:2
    int pre_type_flag = 0;      //default:0  int:1  double:2

    int symbol_num = 0;         //number of symbol 
    char str[100];              //for communication with *.y
%}

%x COMMENT
%x COMMENT2
%x STR

 /***********Regular Expressions***********/
letter      [a-zA-Z]
digit       [0-9]
id          {letter}+({letter}|{digit})*
integer     ([0-9]|-[0-9])+[0-9]*
float       {integer}\.[0-9]+
sem         [;]
space       [ ]
%%

 /******************Translation rule*******************/
"//"                {BEGIN COMMENT;}
<COMMENT>[^\n]+     {;}
<COMMENT>\n         {yylineno++;BEGIN INITIAL;}

"/*"                {BEGIN COMMENT2;}
<COMMENT2>.         {;}
<COMMENT2>"*/"      {BEGIN INITIAL;}
<COMMENT2>\n        {yylineno++;}

"\""                {str[0]='\0';BEGIN STR;}
<STR>"\\"           {;}
<STR>"\\\""         {strcat(str, "\"");}
<STR>"\\\\"         {;}
<STR>"\\n"          {;}
<STR>"\\a"          {;}
<STR>"\\b"          {;}
<STR>"\\f"          {;}
<STR>"\\r"          {;}
<STR>"\\t"          {;}
<STR>"\\v"          {;}
<STR>"\\\?"         {;}
<STR>"\\\'"         {;}
<STR>"\""           {BEGIN INITIAL;strcpy(yylval.str, str);return STRING;}
<STR>.              {strcat(str, yytext);}

 /****Constant****/
{integer}           {yylval.double_val=atoi(yytext);return NUMBER;}
{float}             {yylval.double_val=atof(yytext);return FLOATNUM;}

 /****Delimiters****/
{sem}           {
                    type_flag = 0;
                    pre_type_flag = 0;
                    return SEM;
                }
","             {type_flag = pre_type_flag;}
"("             {return LB;}
")"             {return RB;}
"{"             {;}
"}"             {;}
"["             {;}
"]"             {;}
"\n"            {yylineno++;}
" "             {}
"\t"            {}

 /****Operators****/
"+"             {return ADD;}
"-"             {return SUB;}
"*"             {return MUL;}
"/"             {return DIV;}
"^"             {;}
"%"             {;}
"<"             {;}
"<="            {;}
"=="            {;}
"!="            {;}
">="            {;}
">"             {;}
"="             {type_flag = 0;return ASSIGN;}

 /****Keywords****/
 /*case-insensitive*/
(?i:int)        {
                    type_flag = 1;
                    pre_type_flag = 1;
                    return INT;
                }
(?i:double)     {
                    type_flag = 2;
                    pre_type_flag = 2;
                    return DOUBLE;
                }
(?i:print)      {return PRINT;}
(?i:if)         {;}
(?i:else)       {;}
(?i:while)      {return WHILE;}

 /****Identifiers****/
{id}            {strcpy(yylval.str, yytext);return ID;}

.               {;} /*ignore*/

%%

 /*****************Auxiliary procedures*****************/

int yywrap(void)
{
    return 1;
}

