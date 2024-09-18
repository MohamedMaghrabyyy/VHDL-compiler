%{
#include "y.tab.h"
#include <ctype.h>
#include <string.h>

void yyerror(const char *s);
int yylineno; 

void to_lowercase(char *str) 
{
    for (char *p = str; *p; ++p) *p = tolower(*p);
}
%}

%%

"entity"               { return ENTITY; }
"is"                   { return IS; }
"end"                  { return END; }
"architecture"         { return ARCHITECTURE; }
"signal"               { return SIGNAL; }
"of"                   { return OF; }
"begin"                { return BEGIN_TOK; }

[_a-zA-Z][_a-zA-Z0-9]* {
    char temp[256];
    // Copy the identifier and convert to lowercase
    strncpy(temp, yytext, sizeof(temp));
    temp[sizeof(temp) - 1] = '\0'; 
    char *original_text = strdup(yytext);
    to_lowercase(temp);
    // Check if it's a keyword by comparing with lowercase keywords
    if (strcmp(temp, "entity") == 0) {
        yylval.id = original_text;
        return ENTITY;
    }
    if (strcmp(temp, "is") == 0) {
        yylval.id = original_text;
        return IS;
    }
    if (strcmp(temp, "end") == 0) {
        yylval.id = original_text;
        return END;
    }
    if (strcmp(temp, "architecture") == 0) {
        yylval.id = original_text;
        return ARCHITECTURE;
    }
    if (strcmp(temp, "signal") == 0) {
        yylval.id = original_text;
        return SIGNAL;
    }
    if (strcmp(temp, "of") == 0) {
        yylval.id = original_text;
        return OF;
    }
    if (strcmp(temp, "begin") == 0) {
        yylval.id = original_text;
        return BEGIN_TOK;
    }
    yylval.id = original_text;
    return IDENTIFIER;
}

[ \t\n]                { /* Ignore whitespace */ }
"<="                   { return ASSIGN; }
";"                    { return SEMICOLON; }
":"                    { return COLON; }

. {
    char error_msg[256];
    snprintf(error_msg, sizeof(error_msg), "Invalid identifier: '%s', contains or starts with invalid characters", yytext);
    yyerror(error_msg);
}

%%

int yywrap(void) {
    return 1;
}
