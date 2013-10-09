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

#include <errno.h>
#include <fcntl.h>
#include <getopt.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>

#include <sys/mman.h>
#include <sys/stat.h>

#define MEMSIZE 100

#define ADD (1 * MEMSIZE)
#define SUB (2 * MEMSIZE)
#define STA (3 * MEMSIZE)
#define LDA (5 * MEMSIZE)
#define BRA (6 * MEMSIZE)
#define BRZ (7 * MEMSIZE)
#define BRP (8 * MEMSIZE)
#define IOP (9 * MEMSIZE)
#define INP (IOP + 1)
#define OUT (IOP + 2)
#define HLT 0

/*
 * Check the validity of the mailbox address.
 * It must be between 0 and the smaller of size and MEMSIZE.
 */
static inline void check_addr(int16_t addr, off_t size) {
	if (addr < 0 || addr >= size || addr >= MEMSIZE) {
		fprintf(stderr, "Illegal address: %d\n", addr);
		exit(1);
	}
}

void print_version(void) {

	fprintf(stdout, "%s %s\n", PACKAGE_NAME, PACKAGE_VERSION);

	exit(0);
}

void print_help(char *progname) {

	fprintf(stdout, "LMC - little man computer virtual machine.\n");
	fprintf(stdout, "\n");
	fprintf(stdout, "Usage: %s [OPTION] [filename]\n", progname);
	fprintf(stdout, "\n");
	fprintf(stdout, "Options:\n");
	fprintf(stdout, " -h, -?            --help                  Print a helpful message and exit.\n");
	fprintf(stdout, " -v                --version               Print version information and exit.\n");
	fprintf(stdout, "\n");
	fprintf(stdout, "Report bugs to <%s>.\n", PACKAGE_BUGREPORT);

	exit(0);
}


int main(int argc, char *argv[]) {

	int optc;
	const char* const short_options = "h?v";
	static const struct option long_options[] = {
		{"help", no_argument, NULL, 'h'},
		{"version", no_argument, NULL, 'v'},
		{NULL, 0, NULL, 0}
	};

	int16_t pc; /* program counter */
	int16_t *memory; /* system memory (mailboxes) */
	int16_t inst; /* current instruction */
	int16_t mbox; /* current mailbox */
	int acc; /* accumulator - must be int for fscanf() */

	int fd, rc, done;
	struct stat ss;

	while ((optc = getopt_long(argc, argv, short_options, long_options, NULL)) != -1) {
		 switch (optc) {
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

	fd = open(argv[optind], O_RDONLY);
	if (fd == -1) {
		fprintf(stderr, "open(): %s\n", strerror(errno));
		exit(1);
	}

	rc = fstat(fd, &ss);
	if (rc == -1) {
		fprintf(stderr, "fstat(): %s\n", strerror(errno));
		exit(1);
	}

	memory = mmap(NULL, ss.st_size, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0);
	if (memory == MAP_FAILED) {
		fprintf(stderr, "mmap(): %s\n", strerror(errno));
		exit(1);
	}

	pc = 0;
	acc = 0;
	done = 0;

	/* Main Fetch-Decode-Execute Loop */
	do {
		check_addr(pc, ss.st_size);
		inst = memory[pc];
		pc++;

		mbox = inst % MEMSIZE;
		check_addr(mbox, ss.st_size);

		switch (inst - mbox) {
			case ADD:
				acc += memory[mbox];
				break;
			case SUB:
				acc -= memory[mbox];
				break;
			case STA:
				memory[mbox] = acc;
				break;
			case LDA:
				acc = memory[mbox];
				break;
			case BRA:
				pc = mbox;
				break;
			case BRZ:
				if (acc == 0) pc = mbox;
				break;
			case BRP:
				if (acc >= 0) pc = mbox;
				break;
			case IOP:
				if (inst == INP) {
					fprintf(stdout, "Please enter a number: ");
					fflush(stdout);
					rc = fscanf(stdin, "%d", &acc);
					if (rc == EOF) {
						fprintf(stderr, "EOF\n");
						exit(1);
					}
				} else if (inst == OUT) {
					fprintf(stdout, "%d\n", acc);
				} else {
					fprintf(stderr, "Illegal Instruction: %d\n", inst);
					exit(1);
				}
				break;
			case HLT:
				done = 1;
				break;
			default:
				fprintf(stderr, "Illegal Instruction: %d\n", inst);
				exit(1);
		}

	} while (!done);

	rc = munmap(memory, ss.st_size);
	if (rc == -1) {
		fprintf(stderr, "munmap(): %s\n", strerror(errno));
		exit(1);
	}

	rc = close(fd);
	if (rc == -1) {
		fprintf(stderr, "close(): %s\n", strerror(errno));
		exit(1);
	}

	return 0;
}
