CC     = gcc
LEX    = flex
YACC   = bison
LFLAGS =
YFLAGS = -d
CFLAGS = -Wall -g3
LIBS   = 

BINARY   = lmas
LEXSPEC  = scanner.l
YACCSPEC = parser.y
SOURCES  = $(LEXSPEC:.l=.lex.c) $(YACCSPEC:.y=.y.tab.c)

all: clean $(YACCSPEC:.y=.y.tab.c) $(LEXSPEC:.l=.lex.c) $(SOURCES:.c=.o)
	$(CC) $(LIBS) $(CFLAGS) -o $(BINARY) $(SOURCES:.c=.o)

clean:
	rm -f a.out *.o *.lex.c *.y.tab.? $(BINARY)


.SUFFIXES: .c .o
.c.o:
	$(CC) $(CFLAGS) -o $(<:.c=.o) -c $<

.SUFFIXES: .l .lex.c
.l.lex.c:
	$(LEX) $(LFLAGS) -o$(<:.l=.lex.c) $<

.SUFFIXES: .y .y.tab.c
.y.y.tab.c:
	$(YACC) $(YFLAGS) -b $< $<
