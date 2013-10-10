INP		// Read a number
STA FIRST	// Store it in FIRST
INP		// Read another number
STA SECOND	// Store it in SECOND
LDA FIRST	// Load the FIRST number
SUB SECOND	// Subtract SECOND from FIRST
OUT		// Display the result
HLT		// HALT
FIRST DAT	// Storage area for FIRST number
SECOND DAT	// Storage area for SECOND number
