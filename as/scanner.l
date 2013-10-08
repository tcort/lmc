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

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

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
dat "DAT"

newline "\n"
carriagereturn "\r"
tab "\t"
space " "
eol ({newline}|{carriagereturn}{newline})
empty ({tab}|{space}|{carriagereturn}|{eol})

remark "//"
comment {remark}.*{newline}

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
int main(int argc, char *argv[]) {

	if (argc != 2) {
		fprintf(stderr, "Usage: lmas [filename]\n");
	}

	yyin = fopen(argv[1],"r");
	if (!yyin) {
		perror(argv[1]);
		exit(1);
	}
	yyparse();
	fclose(yyin);

	return 0;
}

