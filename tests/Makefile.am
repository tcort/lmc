TESTS = \
	42.sh		\
	add.sh		\
	basic-io.sh	\
	cob.sh		\
	countdown.sh	\
	io.sh		\
	labels.sh	\
	load-store.sh	\
	sub.sh

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
	42.bin		42.out		\
	add.bin		add.out		\
	basic-io.bin	basic-io.out	\
	cob.bin		cob.out		\
	countdown.bin	countdown.out	\
	io.bin		io.out		\
	labels.bin	labels.out	\
	load-store.bin	load-store.out	\
	sub.bin		sub.out

EXTRA_DIST = test-runner.sh $(TESTS)			\
	42.asm		42.exp				\
	add.asm		add.exp		add.in		\
	basic-io.asm	basic-io.exp	basic-io.in	\
	cob.asm						\
	countdown.asm	countdown.exp			\
	io.asm		io.exp		io.in		\
	labels.asm	labels.exp			\
	load-store.asm	load-store.exp	load-store.in	\
	sub.asm		sub.exp		sub.in
