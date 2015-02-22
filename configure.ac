AC_PREREQ(2.59)
AC_INIT([lmc], [2.0.1], [linuxgeek@gmail.com])
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

if test $cross_compiling = yes; then
	case "$host" in
		*-*-mingw* | *-*-cygwin)
			dnl
			dnl Check for wine
			dnl
			AC_ARG_VAR([WINE],[the 'wine' program for running mingw/cygwin executables.])
			AC_PATH_PROG([WINE],['wine'],[])
			if test "x$WINE" = "x"; then
				AC_MSG_NOTICE([==> wine command not found! see http://www.winehq.org/])
				AC_MSG_NOTICE([==> Set WINE variable if present in non-standard path!])
				AC_MSG_NOTICE([Tests will probably not work without wine.])
			fi
		;;
	esac
fi

AC_CHECK_HEADERS([sys/mman.h])

AC_FUNC_MMAP

AC_CONFIG_HEADERS([config.h:config.in])

AC_CONFIG_FILES([Makefile as/Makefile vm/Makefile tests/Makefile man/Makefile])
AC_OUTPUT
