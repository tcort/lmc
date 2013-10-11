INP		; get the first input
STA FIRST	; store it in FIRST
INP		; get the second input
STA SECOND	; store it in SECOND
LDA FIRST	; load FIRST
OUT		; output value
LDA SECOND	; load SECOND
OUT		; output value
HLT		; end of program
FIRST DAT	; storage
SECOND DAT	; storage
