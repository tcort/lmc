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

#include "config.h"

#include <errno.h>
#include <fcntl.h>
#include <getopt.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>

#ifdef HAVE_SYS_MMAN_H
#include <sys/mman.h>
#endif /* HAVE_SYS_MMAN_H */

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

/*
 * Determine if the session is interactive (i.e. user at a tty) or if
 * we're reading from a file or pipe. This is used to determine if a
 * prompt should be displayed.
 *
 * @param f input stream.
 * @return 1 if session is interactive or 0 if not.
 */
int is_interactive(FILE *f) {

	int fd;

	fd = fileno(f);
	if (fd == -1) {
		return 0;
	}

	return isatty(fd);
}

/**
 * Main Program
 *
 * TODO re-factor
 * Everything in one function probably won't win any design awards.
 *
 * @param argc number of command line arguments.
 * @param argv the command line arguments.
 * @return exit code
 */
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

#ifdef HAVE_MMAP

	memory = mmap(NULL, ss.st_size, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0);
	if (memory == MAP_FAILED) {
		fprintf(stderr, "mmap(): %s\n", strerror(errno));
		exit(1);
	}

#else /* HAVE_MMAP */

	/* if mmap() isn't present, just read the entire file into memory. */

	memory = (int16_t *) malloc(ss.st_size);
	if (memory == NULL) {
		fprintf(stderr, "malloc(): %s\n", strerror(errno));
		exit(1);
	}

	rc = read(fd, memory, ss.st_size);
	if (rc != ss.st_size) {
		fprintf(stderr, "read(): %s\n", strerror(errno));
		exit(1);
	}

#endif /* ! HAVE_MMAP */

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
					if (is_interactive(stdin)) {
						fprintf(stdout, "Please enter a number: ");
						fflush(stdout);
					}

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

#ifdef HAVE_MMAP

	rc = munmap(memory, ss.st_size);
	if (rc == -1) {
		fprintf(stderr, "munmap(): %s\n", strerror(errno));
		exit(1);
	}
	memory = NULL;

#else /* HAVE_MMAP */

	free(memory);
	memory = NULL;

#endif /* ! HAVE_MMAP */

	rc = close(fd);
	if (rc == -1) {
		fprintf(stderr, "close(): %s\n", strerror(errno));
		exit(1);
	}

	return 0;
}
