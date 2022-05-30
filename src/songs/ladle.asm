.include "notes.inc"
.export ladle_pulse, ladle_tri

eighth = 12
quarter = 2 * eighth
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half

.segment "RODATA"
ladle_pulse:
	.byte CMD_SHAPE, $0C
	.byte CMD_DECAY_ON, CMD_SUSTAIN_ON
	.byte A2, eighth
	.byte A3, eighth
	.byte B3, eighth
	.byte A3, eighth
	.byte E4, eighth
	.byte D4, eighth
	.byte A2, eighth
	.byte B3, eighth+eighth
	.byte A2, eighth
	.byte A3, eighth
	.byte A2, eighth
	.byte D4, quarter
	.byte Db4, quarter
	.byte CMD_JUMP
	.word ladle_pulse

ladle_tri:
	.byte CMD_SHAPE, $FF
	.byte A5, half
	.byte E6, whole + half
	.byte D6, half
	.byte A6, whole + half
	.byte D6, half
	.byte E6, whole + half
	.byte A5, half
	.byte D6, whole + half
	.byte CMD_JUMP
	.word ladle_tri
