.include "notes.inc"
.export villain_pulse, villain_tri

eighth = 6
quarter = 2 * eighth
half = 2 * quarter
halfdot = half + quarter
whole = 2 * half
wholedot = whole + half

.segment "RODATA"

villain_pulse:
	.byte CMD_SHAPE, $4F
	.byte CMD_DECAY_ON, CMD_SUSTAIN_OFF
villain_inner:
	.byte F2, eighth
	.byte E2, eighth
	.byte A1, eighth
	.byte Eb2, eighth
	.byte D2, eighth
	.byte A1, eighth
	.byte C2, eighth
	.byte B1, eighth
	.byte CMD_JUMP
	.word villain_inner


villain_tri:
	.byte CMD_SHAPE, $FF
	.byte CMD_JUMP
	.word villain_inner
