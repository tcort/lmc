%{

/*
 * Copyright (c) 2013, 2014 Thomas Cort <linuxgeek@gmail.com>
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
 * Simple scanner. Defines the regular expressions for tokenizing the
 * input source. The main() function is also defined here.
 */

#include "config.h"

#include <getopt.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "hash.h"
#include "parser.h"

extern int lineno;
void yyerror(char *);

#define YY_INPUT(buf,result,max_size) \
	{ \
		int c = fgetc(yyin); \
		result = (c == EOF) ? YY_NULL : (buf[0] = c, 1); \
	}


%}

letter [A-Z]
digit [0-9]

label {letter}+
number {digit}+

add "ADD"
sub "SUB"
sta "STA"
lda "LDA"
bra "BRA"
brz "BRZ"
brp "BRP"
inp "INP"
out "OUT"
hlt "HLT"
cob "COB"
dat "DAT"

newline "\n"
carriagereturn "\r"
tab "\t"
space " "
eol ({newline}|{carriagereturn}{newline})
empty ({tab}|{space}|{carriagereturn}|{eol})

doubleslash "//"
hash "#"
semicolon ";"
comment ({doubleslash}|{hash}|{semicolon}).*{newline}

%option noinput
%option nounput

%%
{comment}	{
			lineno++;
			return EOL;
		}

{add} 		{
			return ADD;
		}

{sub}		{
			return SUB;
		}

{sta} 		{
			return STA;
		}

{lda} 		{
			return LDA;
		}

{bra} 		{
			return BRA;
		}

{brz} 		{
			return BRZ;
		}

{brp}		{
			return BRP;
		}

{inp} 		{
			return INP;
		}

{out} 		{
			return OUT;
		}

{hlt} 		{
			return HLT;
		}

{cob}		{
			/* COB is a synonym for HLT */
			return HLT;
		}

{dat} 		{
			return DAT;
		}

{number}	{
			yylval.number = atoi(yytext);
			return NUMBER;
		}

{label}		{
			yylval.label = strdup(yytext);
			return LABEL;
		}

{eol}		{
			lineno++;
			return EOL;
		}

{empty}		{
			/* skip whitespace */
			break;
		}

.		{
			yyerror ("Invalid Syntax");
		}

%%

int yyparse();
int yywrap() {
	return 1;
}

int lineno = 0;
char *output_filename = "a.out";
hash_t *symtab;

/**
 * Print the package name and version number, then exit().
 */
void print_version(void) {

	fprintf(stdout, "%s %s\n", PACKAGE_NAME, PACKAGE_VERSION);
	exit(0);
}

/**
 * Prints the usage information and available command line options, then exit().
 *
 * @param progname the name of the program
 */
void print_help(char *progname) {

	fprintf(stdout, "LMC - little man computer assembler.\n");
	fprintf(stdout, "\n");
	fprintf(stdout, "Usage: %s [OPTION] [filename]\n", progname);
	fprintf(stdout, "\n");
	fprintf(stdout, "Options:\n");
	fprintf(stdout, " -o [filename]     --output [filename]     Specify the output filename.\n");
	fprintf(stdout, " -h, -?            --help                  Print a helpful message and exit.\n");
	fprintf(stdout, " -v                --version               Print version information and exit.\n");
	fprintf(stdout, "\n");
	fprintf(stdout, "Report bugs to <%s>.\n", PACKAGE_BUGREPORT);

	exit(0);
}

/**
 * Main driver program.
 *
 * @param argc number of command line arguments.
 * @param argv the command
 * @return exit code
 */
int main(int argc, char *argv[]) {

	int optc;

	const char* const short_options = "o:h?v";
	static const struct option long_options[] = {
		{"help", no_argument, NULL, 'h'},
		{"version", no_argument, NULL, 'v'},
		{"output", required_argument, NULL, 'o'},
		{NULL, 0, NULL, 0}
	};

	while ((optc = getopt_long(argc, argv, short_options, long_options, NULL)) != -1) {
		switch (optc) {
			case 'o':
				output_filename = optarg;
				break;
			case 'v':
				print_version();
				break;
			case 'h':
			case '?':
				print_help(argv[0]);
				break;
		}
	}

	if (optind + 1 != argc) {
		print_help(argv[0]);
	}

	symtab = hash_new();
	yyin = fopen(argv[optind], "r");
	if (!yyin) {
		perror(argv[optind]);
		exit(1);
	}
	yyparse();
	fclose(yyin);
	hash_free(symtab);
	symtab = NULL;

	return 0;
}

