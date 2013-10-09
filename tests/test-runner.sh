#!/bin/sh

ASM=${LMC_IN_DIR}/${1}.asm
BIN=${LMC_OUT_DIR}/${1}.bin
OUT=${LMC_OUT_DIR}/${1}.out
EXP=${LMC_EX_DIR}/${1}.exp

if test "x${DIFF}" = "x"; then
	# no diff program, skipping test
	exit 77
fi

${LMAS} -o ${BIN} ${ASM}
${LMVM} ${BIN} > ${OUT}

${DIFF} -u ${EXP} ${OUT}

RESULT=$?
if [ $RESULT -gt 0 ]
then
	exit 1
else
	exit 0
fi
