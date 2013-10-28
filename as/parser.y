%{

/*
 * Copyright (c) 2013 Thomas Cort <linuxgeek@gmail.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */


/*
 * Simple 2 pass assembler.
 *
 * This file handles the parsing of the assembly language code and the
 * emitting of virtual machine code. As the code is parsed, a list of
 * statements (abstract syntax tree) is constructed in memory and a
 * symbol table is created. When parsing is complete, the program iterates
 * over the statement list generating machine code and outputting it to a file.
 */

#define _BSD_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

#define MEMSIZE 100
#define ADD_INST (1 * MEMSIZE)
#define SUB_INST (2 * MEMSIZE)
#define STA_INST (3 * MEMSIZE)
#define LDA_INST (5 * MEMSIZE)
#define BRA_INST (6 * MEMSIZE)
#define BRZ_INST (7 * MEMSIZE)
#define BRP_INST (8 * MEMSIZE)
#define IOP_INST (9 * MEMSIZE)
#define INP_INST (IOP_INST + 1)
#define OUT_INST (IOP_INST + 2)
#define HLT_INST 0

/* Globals */
extern char *output_filename;
extern int lineno;
extern int yylex();

/* Prototypes */
int yyerror(char* str);

/**
 * Item in a linked list representing an assembly language program.
 * It is our abstract syntax tree.
 */
struct statement {
	int16_t inst;
	char *label;
	struct statement *next;
};

/**
 * Allocate a statement on the heap and initialize the inst and label
 * fields with the given parameters.
 *
 * @param inst the instruction code (without target address).
 * @param label if this instruction has a target label, pass it here.
 * @return a new statement or NULL.
 */
struct statement *new_statement(int16_t inst, char *label) {

	struct statement *stmt;

	stmt = (struct statement *) malloc(sizeof(struct statement));
	if (stmt == NULL) {
		fprintf(stderr, "malloc(): %s\n", strerror(errno));
		exit(1);
	}

	stmt->inst = inst;
	stmt->label = label;
	stmt->next = NULL;

	return stmt;
}

/**
 * Add a statement to the end of the list.
 */
void statement_append(struct statement *list, struct statement *stmt) {

	struct statement *cur;

	cur = list;

	/* TODO re-factor
	 * it isn't very efficient to walk the list for each insertion.
	 * instead we should maintain a pointer to the last element.
	 * not a big deal since LMC programs are <= 100 lines long.
	 */
	while (cur && cur->next) {
		cur = cur->next;
	}

	cur->next = stmt;
}

/**
 * Label is a linked list of line numbers and strings. It is our symbol table.
 */
struct label {
	int lineno;
	char *label;
	struct label *next;
};

/**
 * Symbol Table
 */
struct label *label_head = NULL;

struct label * label_lookup(char *_label) {

	struct label *cur;

	/* TODO re-factor
	 * it isn't very efficient to do a linear search for every symbol.
	 * instead we should use a hash table or other ADT with O(1) get().
	 * not a big deal since LMC programs are <= 100 lines long.
	 */
	
	for (cur = label_head; cur != NULL; cur = cur->next) {
		if (strncmp(cur->label, _label, strlen(_label)) == 0) {
			return cur;
		}
	}

	return NULL;
}

/**
 * Add a label with it's line number to the symbol table.
 *
 * @param _label the label.
 * @param _lineno the line that the label resides on.
 */
void label_insert(char *_label, int _lineno) {
	struct label *cur;

	cur = label_lookup(_label);
	if (cur != NULL) {
		fprintf(stderr, "Duplicate label '%s'\n", _label);
		exit(1);
	}

	/* TODO refactor
	 * adding a label to the list should be a separate function from
	 * creating a new label.
	 */
	cur = (struct label *) malloc(sizeof(struct label));
	if (cur == NULL) {
		fprintf(stderr, "malloc: %s\n", strerror(errno));
		exit(1);
	}

	cur->label = _label;
	cur->lineno = _lineno;
	cur->next = label_head;
	
	label_head = cur;
}

%}
 
%union {
	struct statement *stmt;
	char *label;
	int number;
};

/* keywords */
%token ADD SUB STA LDA BRA BRZ BRP INP OUT HLT DAT

/* tokens */
%token EOL

%token <label> LABEL
%token <number> NUMBER

%type <stmt> statement line lines
%type <number> data

%%

program : lines
		{
			int rc;
			FILE *fp;
			struct statement *stmt, *next_stmt;

			/* open output file */
			fp = fopen(output_filename, "wb");
			if (fp == NULL) {
				fprintf(stderr, "fopen(): %s\n", strerror(errno));
				exit(1);
			}

			/* iterate over the list of statements */
			for (stmt = $1; stmt != NULL; stmt = next_stmt) {

				/* look up label if needed, decorate AST */
				if (stmt->label) {
					struct label *label;
					label = label_lookup(stmt->label);

					if (label == NULL) {
						fprintf(stderr, "Undefined label '%s'\n", stmt->label);
						exit(1);
					}

					stmt->inst += label->lineno;
				}

				/* emit machine code */
				rc = fwrite(&stmt->inst, sizeof(stmt->inst), 1, fp);
				if (rc != 1) {
					fprintf(stderr, "fwrite(): %s\n", strerror(errno));
					exit(1);
				}

				/* clean up */
				if (stmt->label) free(stmt->label);
				next_stmt = stmt->next;
				free(stmt);

			}

			/* close output file */
			rc = fclose(fp);
			if (rc == -1) {
				fprintf(stderr, "fclose(): %s\n", strerror(errno));
				exit(1);
			}

			/* free symbol table */

			struct label *cur, *next_label;

			for (cur = label_head; cur != NULL; cur = next_label) {
				free(cur->label);
				next_label = cur->next;
				free(cur);
			}
		}
	;

lines	: lines line { statement_append($1, $2); }
	| line { $$ = $1; }
	;

line	:	LABEL statement EOL
		{
			label_insert($1, lineno - 1);
			$$ = $2;
		}
	|	statement EOL { $$ = $1; }
	;

statement	:	ADD LABEL { $$ = new_statement(ADD_INST, $2); }
		|	SUB LABEL { $$ = new_statement(SUB_INST, $2); }
		|	STA LABEL { $$ = new_statement(STA_INST, $2); }
		|	LDA LABEL { $$ = new_statement(LDA_INST, $2); }
		|	BRA LABEL { $$ = new_statement(BRA_INST, $2); }
		|	BRZ LABEL { $$ = new_statement(BRZ_INST, $2); }
		|	BRP LABEL { $$ = new_statement(BRP_INST, $2); }
		|	INP { $$ = new_statement(INP_INST, NULL); }
		|	OUT { $$ = new_statement(OUT_INST, NULL); }
		|	HLT { $$ = new_statement(HLT_INST, NULL); }
		|	data { $$ = new_statement($1, NULL); }
		;

data	: DAT NUMBER { $$ = $2; }
	| DAT { $$ = 0; }
	;

%%

/**
 * A parse error occurred, print an error message and exit().
 *
 * @param error message.
 * @return should not return, but if it does a -1 will be returned.
 */
int yyerror(char* str) {
	fprintf(stderr,"yyerror: %s (line %d)\n", str, lineno + 1);
	exit(1);
	return -1; /* should not get here */
}
