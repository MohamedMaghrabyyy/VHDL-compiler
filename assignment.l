%{
#include "y.tab.h"
#include <ctype.h>

void yyerror(const char *s);
int yylineno;  // To track the current line number in Flex
%}

%%

"entity"               { yylval.id = strdup("entity"); return ENTITY; }
"is"                   { yylval.id = strdup("is"); return IS; }
"end"                  { yylval.id = strdup("end"); return END; }
"architecture"         { yylval.id = strdup("architecture"); return ARCHITECTURE; }
"signal"               { yylval.id = strdup("signal"); return SIGNAL; }
"of"                   { yylval.id = strdup("of"); return OF; }
"begin"                { yylval.id = strdup("begin"); return BEGIN_TOK; }

[_a-zA-Z][_a-zA-Z0-9]* { yylval.id = strdup(yytext); return IDENTIFIER; }

[ \t\n]                { /* Ignore whitespace */ }
"<="                   { return ASSIGN; }
";"                    { return SEMICOLON; }
":"                    { return COLON; }

.                      { yyerror("unexpected character"); }

%%

int yywrap(void) {
    return 1;
}

