%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

void yyerror(const char *s);
extern int yylex();
extern int yylineno;

#define MAX_SIGNALS 100

typedef struct {
    char *name;
    char *type;
} Signal;

Signal signals[MAX_SIGNALS];
int signal_count = 0;

char *entity_name = NULL;

void add_signal(char *name, char *type);
int signal_exists(char *name);
char* get_signal_type(char *name);
int signal_type_matches(char *source, char *destination);
%}

%union { char *id; }

%token <id> ENTITY IS END ARCHITECTURE SIGNAL IDENTIFIER NUMBER OF COLON SEMICOLON BEGIN_TOK
%token <id> ASSIGN

%type <id> program entity_decl architecture_decl signal_decl assignment

%%

program:
    entity_decl architecture_decl
    ;

entity_decl:
    ENTITY IDENTIFIER IS END SEMICOLON
    {
        if (entity_name) {
            free(entity_name);
        }
        entity_name = strdup($2);
        printf("Entity declaration: %s\n", $2);
        free($2);
    }
    ;

architecture_decl:
    ARCHITECTURE IDENTIFIER OF IDENTIFIER IS signal_decl BEGIN_TOK assignment END SEMICOLON
    {
        if (entity_name == NULL) 
        {
            yyerror("No entity declared.");
        }
        else if (strcasecmp(entity_name, $4) != 0) 
        {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                     "Entity name in architecture '%s' does not match declared entity '%s'.",
                     $4, entity_name);
            yyerror(error_msg);
        }
        else 
        {
            printf("Architecture declaration: %s for entity: %s\n", $2, $4);
        }
        free($2);
        free($4);
    }
    ;

signal_decl:
    SIGNAL IDENTIFIER COLON IDENTIFIER SEMICOLON
    {
        add_signal($2, $4);
        printf("Signal declaration: %s of type %s\n", $2, $4);
        free($2);
        free($4);
    }
    | signal_decl SIGNAL IDENTIFIER COLON IDENTIFIER SEMICOLON
    {
        add_signal($3, $5);
        printf("Signal declaration: %s of type %s\n", $3, $5);
        free($3);
        free($5);
    }
    ;

assignment:
    IDENTIFIER ASSIGN IDENTIFIER SEMICOLON
    {
        if (!signal_exists($1)) 
        {
            char error_msg[100];
            snprintf(error_msg, sizeof(error_msg), "Unknown signal '%s'", $1);
            yyerror(error_msg);
        }
        if (!signal_exists($3)) 
        {
            char error_msg[100];
            snprintf(error_msg, sizeof(error_msg), "Unknown signal '%s'", $3);
            yyerror(error_msg);
        }
        if (!signal_type_matches($1, $3)) 
        {
            yyerror("Signal types don't match.");
        }
        else 
        {
            printf("Assignment: %s <= %s\n", $1, $3);
        }
        free($1);
        free($3);
    }
    | assignment IDENTIFIER ASSIGN IDENTIFIER SEMICOLON
    {
        if (!signal_exists($2)) 
        {
            char error_msg[100];
            snprintf(error_msg, sizeof(error_msg), "Unknown signal '%s'", $2);
            yyerror(error_msg);
        }
        if (!signal_exists($4)) 
        {
            char error_msg[100];
            snprintf(error_msg, sizeof(error_msg), "Unknown signal '%s'", $4);
            yyerror(error_msg);
        }
        if (!signal_type_matches($2, $4)) 
        {
            yyerror("Signal types don't match.");
        }
        else 
        {
            printf("Assignment: %s <= %s\n", $2, $4);
        }
        free($2);
        free($4);
    }
    ;

%%

void add_signal(char *name, char *type) 
{
    for (int i = 0; i < signal_count; i++) 
    {
        if (strcmp(signals[i].name, name) == 0) 
        {
            char error_msg[100];
            snprintf(error_msg, sizeof(error_msg), "Redeclaration of signal '%s'", name);
            yyerror(error_msg);
            exit(EXIT_FAILURE);
        }
    }
    signals[signal_count].name = strdup(name);
    signals[signal_count].type = strdup(type);
    signal_count++;
}

int signal_exists(char *name) 
{
    for (int i = 0; i < signal_count; i++) 
    {
        if (strcmp(signals[i].name, name) == 0) 
            return 1;  
    }
    return 0;
}

char* get_signal_type(char *name) 
{
    for (int i = 0; i < signal_count; i++) 
    {
        if (strcmp(signals[i].name, name) == 0)
            return signals[i].type;
    }
    return NULL;
}

int signal_type_matches(char *source, char *destination) 
{
    char *source_type = get_signal_type(source);
    char *destination_type = get_signal_type(destination);

    if (source_type == NULL) 
    {
        fprintf(stderr, "Error: Source signal '%s' type not found.\n", source);
        return 0;
    }
    if (destination_type == NULL) 
    {
        fprintf(stderr, "Error: Destination signal '%s' type not found.\n", destination);
        return 0;
    }
    if (strcmp(source_type, destination_type) != 0) 
    {
        fprintf(stderr, "Error: Type mismatch: signal '%s' is of type '%s', but assignment is to '%s' of type '%s'\n",
                source, source_type, destination, destination_type);
        return 0;
    }
    return 1;
}

int main() 
{
    return yyparse();
}

void yyerror(const char *s) 
{
    fprintf(stderr, "Error: %s\n", s);
}
