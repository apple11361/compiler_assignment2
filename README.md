# compiler_assignment2
compiler_assignment2

# usage

source code in F74036166_HW2/

yacc -d Compiler_F74036166_HW2.y  
lex Compiler_F74036166_HW2.l  
gcc lex.yy.c y.tab.c -o main  
