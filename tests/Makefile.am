TESTS = \
	42.sh \
	cob.sh \
	countdown.sh

TESTS_ENVIRONMENT = \
	WINE=$(WINE)					\
	DIFF=$(DIFF)					\
	LMAS=$(top_builddir)/as/lmas			\
	LMVM=$(top_builddir)/vm/lmvm			\
	LMC_IN_DIR=$(top_srcdir)/tests			\
	LMC_OUT_DIR=$(top_builddir)/tests		\
	LMC_EX_DIR=$(top_srcdir)/tests			\
	TEST_RUNNER=$(top_srcdir)/tests/test-runner.sh

CLEANFILES = \
	42.bin		42.out	\
	cob.bin		cob.out	\
	countdown.bin	countdown.out

EXTRA_DIST = test-runner.sh $(TESTS)	\
	42.asm		42.exp		\
	cob.asm				\
	countdown.asm	countdown.exp
