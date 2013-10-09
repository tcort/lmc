AC_PREREQ(2.59)
AC_INIT([lmc], [1.0-SNAPSHOT], [linuxgeek@gmail.com])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])
AM_SILENT_RULES([yes])

AC_PROG_CC
AC_PROG_LEX
AC_PROG_YACC

AC_ARG_VAR([DIFF],[the 'diff' program to use for test output comparison])
AC_PATH_PROG([DIFF],[diff],[])
if test "x$DIFF" = "x"; then
	AC_MSG_NOTICE([==> diff command not found!])
	AC_MSG_NOTICE([==> Set DIFF variable if present in non-standard path!])
	AC_MSG_NOTICE([diff is mandatory to run the tests])
fi

AC_CHECK_HEADERS([sys/mman.h])

AC_FUNC_MMAP

AC_CONFIG_HEADERS([config.h:config.in])

AC_CONFIG_FILES([Makefile as/Makefile vm/Makefile tests/Makefile])
AC_OUTPUT
